ZIP_BRANCH := $(shell git rev-parse --abbrev-ref HEAD | sed 's/\//_/g')
ZIP_NAME := UHD_$(ZIP_BRANCH).zip

.PHONY: zip clean

zip:
	@echo "Creating $(ZIP_NAME)..."
	git archive --format=zip --output=$(ZIP_NAME) HEAD

clean:
	@echo "Cleaning zip files..."
	rm -f UHD_*.zip

