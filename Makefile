run:
	@./monitor.sh
	
check:
	@cat temp/Monitor.log

test:
	make run
	make check
	
clean:
	@rm temp/* -f

.PHONY: run check clean test
