- [Version 1.7.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-09-20 Sun]</span></span>](#org88a6da3)
- [Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>](#org03c0e34)
- [Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>](#org72acd0b)
- [Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>](#orgbd22d5f)
- [Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>](#org3038de9)
- [Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>](#org2cb2b79)
- [Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>](#orgdf2d64b)
- [Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>](#orgaa2d7a4)
- [Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>](#org58ea9ac)
- [Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>](#org8f68c13)
- [Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>](#org37dff59)


<a id="org88a6da3"></a>

# Version 1.7.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-09-20 Sun]</span></span>

-   Added a new &ndash;print-option config to pass printer config options to the print-command.


<a id="org03c0e34"></a>

# Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>

-   Improved labrat.el to ensure that the **labrat** buffer gets created and logs the command used along with a timestamp and any errors.
-   Echo the output file name after creation.
-   Add the process number to file name to prevent name collisions.
-   Fix use of XDG\_DATA\_HOME environment variable.


<a id="org72acd0b"></a>

# Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>

-   Added a `vim` plugin to allow printing or viewing labels from within a vim buffer as was possible in Emacs with `labrat.el`.


<a id="orgbd22d5f"></a>

# Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>

-   By default, labrat no longer puts the output file in labrat.pdf; instead, all labels go to `~/.local/share/labrat` and uses the run time for a time-stamp file name.
-   Output file can still be overridden with the `-o` or `--out-file` option


<a id="org3038de9"></a>

# Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>

-   No user-visible changes


<a id="org2cb2b79"></a>

# Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>

-   Used `fat_config` gem to read config files


<a id="orgdf2d64b"></a>

# Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>

-   Fixed `labrat.el` view command


<a id="orgaa2d7a4"></a>

# Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>

-   Changed `nl-sep` to '~~'
-   Changed `label-sep` to '@@'
-   Minor bug fixes


<a id="org58ea9ac"></a>

# Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>

-   Changed `nl-sep` to '&ndash;>'
-   Changed `label-sep` to '==>'
-   Added label name to template output


<a id="org8f68c13"></a>

# Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>

-   Nothing important


<a id="org37dff59"></a>

# Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>

-   Initial release
