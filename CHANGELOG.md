* **Oct 13, 2023:**
    * Added Compose files.
    * Improved Dockerfile:
      - Download the server sources from a git repository instead of dealing with a tarball.
      - Add support for ARM compilation (thanks [@jpelizza](https://github.com/jpelizza)).
      - Set-up minimal dependencies on the final container.
      - Expose all environment variables with default values.
    * Improved start-up script by make it simpler (and cooler) with dynamic password support.
    * Improved README.
---
* **Sep 15, 2021:**
    * Initial release