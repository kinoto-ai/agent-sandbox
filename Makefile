.PHONY: build build-proxy build-runtime test test-ci clean

PROXY_LEVELS := zerotrust restrictive balanced permissive
ASSISTANTS := claude gemini codex

# Build all images
build: build-proxy build-runtime

build-proxy:
	@for level in $(PROXY_LEVELS); do \
		echo "Building proxy-$$level..."; \
		docker build -q -t proxy-$$level --build-arg SECURITY_LEVEL=$$level ./proxy > /dev/null; \
	done

build-runtime:
	@for assistant in $(ASSISTANTS); do \
		echo "Building runtime-$$assistant..."; \
		docker build -q -t runtime-$$assistant ./runtime/$$assistant > /dev/null; \
	done

# Full tests (local with CAP_NET_ADMIN)
test: build
	@echo "\n=== Testing proxy tools ==="
	@for level in $(PROXY_LEVELS); do \
		printf "  proxy-$$level: "; \
		docker run --rm --entrypoint sh proxy-$$level -c \
			'which sshd >/dev/null && which tmux >/dev/null && which docker >/dev/null && which iptables >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing runtime tools ==="
	@for assistant in $(ASSISTANTS); do \
		printf "  runtime-$$assistant: "; \
		docker run --rm --entrypoint sh runtime-$$assistant -c \
			'which ssh >/dev/null && which node >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing assistant binaries ==="
	@printf "  claude: "; docker run --rm --entrypoint sh runtime-claude -c 'which claude >/dev/null && echo PASS || echo FAIL'
	@printf "  gemini: "; docker run --rm --entrypoint sh runtime-gemini -c 'which gemini >/dev/null && echo PASS || echo FAIL'
	@printf "  codex: "; docker run --rm --entrypoint sh runtime-codex -c 'which codex >/dev/null && echo PASS || echo FAIL'
	@echo "\n=== Testing iptables (requires CAP_NET_ADMIN) ==="
	@printf "  iptables rules: "; \
	docker run --rm --cap-add=NET_ADMIN \
		-e SECURITY_LEVEL=balanced \
		-e USER_CONTAINER_NAME=test \
		-e AUTHORIZED_KEY="ssh-ed25519 AAAA test" \
		--entrypoint sh proxy-balanced -c \
		'/entrypoint.sh & sleep 2; iptables -L OUTPUT -n 2>/dev/null | grep -q DROP && echo PASS || echo FAIL' 2>/dev/null
	@$(MAKE) test-integration CAP_NET_ADMIN=true
	@echo "\n=== ALL TESTS PASSED ==="

# CI tests (no CAP_NET_ADMIN, permissive mode)
test-ci: build
	@echo "\n=== Testing proxy tools ==="
	@for level in $(PROXY_LEVELS); do \
		printf "  proxy-$$level: "; \
		docker run --rm --entrypoint sh proxy-$$level -c \
			'which sshd >/dev/null && which tmux >/dev/null && which docker >/dev/null && which iptables >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing runtime tools ==="
	@for assistant in $(ASSISTANTS); do \
		printf "  runtime-$$assistant: "; \
		docker run --rm --entrypoint sh runtime-$$assistant -c \
			'which ssh >/dev/null && which node >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing assistant binaries ==="
	@printf "  claude: "; docker run --rm --entrypoint sh runtime-claude -c 'which claude >/dev/null && echo PASS || echo FAIL'
	@printf "  gemini: "; docker run --rm --entrypoint sh runtime-gemini -c 'which gemini >/dev/null && echo PASS || echo FAIL'
	@printf "  codex: "; docker run --rm --entrypoint sh runtime-codex -c 'which codex >/dev/null && echo PASS || echo FAIL'
	@echo "\n=== Skipping iptables test (CI mode) ==="
	@$(MAKE) test-integration CAP_NET_ADMIN=false
	@echo "\n=== ALL TESTS PASSED ==="

# Integration test
test-integration:
	@echo "\n=== Integration test ==="
	@docker rm -f kinoto-user kinoto-proxy 2>/dev/null || true
	@docker network rm kinoto-testnet 2>/dev/null || true
	@rm -f /tmp/kinoto-test-key /tmp/kinoto-test-key.pub
	@ssh-keygen -t ed25519 -f /tmp/kinoto-test-key -N "" -q
	@docker network create kinoto-testnet > /dev/null
	@docker run -d --name kinoto-user --network kinoto-testnet alpine sleep 300 > /dev/null
	@if [ "$(CAP_NET_ADMIN)" = "true" ]; then \
		docker run -d --name kinoto-proxy --network kinoto-testnet \
			--cap-add=NET_ADMIN \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-e AUTHORIZED_KEY="$$(cat /tmp/kinoto-test-key.pub)" \
			-e USER_CONTAINER_NAME=kinoto-user \
			-e SECURITY_LEVEL=balanced \
			proxy-balanced > /dev/null; \
	else \
		docker run -d --name kinoto-proxy --network kinoto-testnet \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-e AUTHORIZED_KEY="$$(cat /tmp/kinoto-test-key.pub)" \
			-e USER_CONTAINER_NAME=kinoto-user \
			-e SECURITY_LEVEL=permissive \
			proxy-balanced > /dev/null; \
	fi
	@sleep 4
	@printf "  SSH through proxy: "
	@docker run --rm --network kinoto-testnet \
		-v /tmp/kinoto-test-key:/tmp/key:ro \
		alpine sh -c ' \
			apk add -q openssh-client 2>/dev/null; \
			cp /tmp/key /root/key && chmod 600 /root/key; \
			ssh -i /root/key -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@kinoto-proxy "echo PASS" 2>/dev/null \
		' || echo "FAIL"
	@docker rm -f kinoto-proxy kinoto-user > /dev/null 2>&1
	@docker network rm kinoto-testnet > /dev/null 2>&1
	@rm -f /tmp/kinoto-test-key /tmp/kinoto-test-key.pub

clean:
	@docker rm -f kinoto-proxy kinoto-user 2>/dev/null || true
	@docker network rm kinoto-testnet 2>/dev/null || true
	@for level in $(PROXY_LEVELS); do docker rmi -f proxy-$$level 2>/dev/null || true; done
	@for assistant in $(ASSISTANTS); do docker rmi -f runtime-$$assistant 2>/dev/null || true; done
