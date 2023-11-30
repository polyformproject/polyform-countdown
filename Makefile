formatted.md: form.md
	fmt -u -w62 < $< > $@

.PHONY: clean

clean:
	rm -f formatted.md
