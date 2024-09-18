.PHONY: test
test:
	flow test --cover --covercode="contracts" tests/*.cdc

.PHONY: ci
ci:
	flow test --cover --covercode="contracts" tests/*.cdc
