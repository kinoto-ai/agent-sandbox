.PHONY: build build-base test test-ci clean

ASSISTANTS := claude gemini codex

# Build base image
build-base:
	@echo "Building base..."
	@docker build -q -t agent-base ./base > /dev/null

# Build all images
build: build-base
	@for assistant in $(ASSISTANTS); do \
		echo "Building $$assistant..."; \
		docker build -q -t agent-$$assistant ./$$assistant > /dev/null; \
	done

# Full tests (local with CAP_NET_ADMIN)
test: build
	@echo "\n=== Testing tools ==="
	@for assistant in $(ASSISTANTS); do \
		printf "  $$assistant: "; \
		docker run --rm --entrypoint sh agent-$$assistant -c \
			'which tmux >/dev/null && which iptables >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing assistant binaries ==="
	@printf "  claude: "; docker run --rm --entrypoint sh agent-claude -c 'which claude >/dev/null && echo PASS || echo FAIL'
	@printf "  gemini: "; docker run --rm --entrypoint sh agent-gemini -c 'which gemini >/dev/null && echo PASS || echo FAIL'
	@printf "  codex: "; docker run --rm --entrypoint sh agent-codex -c 'which codex >/dev/null && echo PASS || echo FAIL'
	@echo "\n=== Testing iptables (requires CAP_NET_ADMIN) ==="
	@printf "  iptables rules: "; \
	docker run --rm --cap-add=NET_ADMIN \
		--entrypoint sh agent-claude -c \
		'/entrypoint.sh & sleep 2; iptables -L OUTPUT -n 2>/dev/null | grep -q DROP && echo PASS || echo FAIL' 2>/dev/null
	@echo "\n=== Testing entrypoint ==="
	@printf "  runs command: "; \
	docker run --rm --cap-add=NET_ADMIN \
		-e ASSISTANT_CMD="echo session-ok" \
		agent-claude 2>&1 | grep -q "session-ok" && echo "PASS" || echo "FAIL"
	@echo "\n=== ALL TESTS COMPLETE ==="

# CI tests (no CAP_NET_ADMIN)
test-ci: build
	@echo "\n=== Testing tools ==="
	@for assistant in $(ASSISTANTS); do \
		printf "  $$assistant: "; \
		docker run --rm --entrypoint sh agent-$$assistant -c \
			'which tmux >/dev/null && which iptables >/dev/null && echo PASS' || echo "FAIL"; \
	done
	@echo "\n=== Testing assistant binaries ==="
	@printf "  claude: "; docker run --rm --entrypoint sh agent-claude -c 'which claude >/dev/null && echo PASS || echo FAIL'
	@printf "  gemini: "; docker run --rm --entrypoint sh agent-gemini -c 'which gemini >/dev/null && echo PASS || echo FAIL'
	@printf "  codex: "; docker run --rm --entrypoint sh agent-codex -c 'which codex >/dev/null && echo PASS || echo FAIL'
	@echo "\n=== Skipping iptables test (CI mode) ==="
	@echo "\n=== ALL TESTS COMPLETE ==="

clean:
	@docker rmi -f agent-base 2>/dev/null || true
	@for assistant in $(ASSISTANTS); do docker rmi -f agent-$$assistant 2>/dev/null || true; done
