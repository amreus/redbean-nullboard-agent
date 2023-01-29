SHELL = cmd
CP = copy
RM = del

agent.com: .init.lua nullboard.html redbean.com
	$(CP) redbean.com agent.com
	zip -u agent.com .init.lua nullboard.html

redbean.com:
	curl -s https://redbean.dev/redbean-tiny-2.2.com > redbean.com

nullboard.html:
	curl -s https://raw.githubusercontent.com/apankrat/nullboard/master/nullboard.html > nullboard.html

.PHONY: clean

clean:
	$(RM) *.com *.html
