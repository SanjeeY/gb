#!/bin/bash
echo "app-portage/layman ~amd64" >> /etc/portage/package.accept_keywords
echo "app-portage/layman sync-plugin-portage" >> /etc/portage/package.use/layman
emerge =app-portage/layman-2.3.0
