app_name = dominika_scraper_1

debug:
	docker attach $(app_name)

console:
	echo -ne "\033]0;In $(app_name) console\007" && irb

to_container:
	echo -ne "\033]0;In $(app_name) container\007" && docker exec -it $(app_name) sh

run:
	echo -ne "\033]0;Running $(app_name)...\007" && docker-compose up

run_and_build:
	echo -ne "\033]0;Running $(app_name)...\007" && docker-compose up --build
