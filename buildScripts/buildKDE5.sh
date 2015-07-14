#!/bin/bash
printf "app-portage/layman ~amd64" >> /etc/portage/package.accept_keywords
printf "app-portage/layman sync-plugin-portage" >> /etc/portage/package.use/layman
emerge =app-portage/layman-2.3.0
