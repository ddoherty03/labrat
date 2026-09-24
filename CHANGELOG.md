- [Version 1.7.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-09-20 Sun]</span></span>](#org39f2c5b)
- [Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>](#orgaa34c3c)
- [Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>](#org9b57373)
- [Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>](#orga6f4b07)
- [Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>](#org021ee2f)
- [Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>](#org53e2731)
- [Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>](#org67ab7ec)
- [Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>](#orgce95977)
- [Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>](#org7038146)
- [Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>](#org64aaa99)
- [Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>](#org87b30d1)


<a id="org39f2c5b"></a>

# Version 1.7.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-09-20 Sun]</span></span>

-   Added a new &ndash;print-option config to pass printer config options to the print-command.


<a id="orgaa34c3c"></a>

# Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>

-   Improved labrat.el to ensure that the **labrat** buffer gets created and logs the command used along with a timestamp and any errors.
-   Echo the output file name after creation.
-   Add the process number to file name to prevent name collisions.
-   Fix use of XDG\_DATA\_HOME environment variable.


<a id="org9b57373"></a>

# Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>

-   Added a `vim` plugin to allow printing or viewing labels from within a vim buffer as was possible in Emacs with `labrat.el`.


<a id="orga6f4b07"></a>

# Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>

-   By default, labrat no longer puts the output file in labrat.pdf; instead, all labels go to `~/.local/share/labrat` and uses the run time for a time-stamp file name.
-   Output file can still be overridden with the `-o` or `--out-file` option


<a id="org021ee2f"></a>

# Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>

-   No user-visible changes


<a id="org53e2731"></a>

# Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>

-   Used `fat_config` gem to read config files


<a id="org67ab7ec"></a>

# Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>

-   Fixed `labrat.el` view command


<a id="orgce95977"></a>

# Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>

-   Changed `nl-sep` to '~~'
-   Changed `label-sep` to '@@'
-   Minor bug fixes


<a id="org7038146"></a>

# Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>

-   Changed `nl-sep` to '&ndash;>'
-   Changed `label-sep` to '==>'
-   Added label name to template output


<a id="org64aaa99"></a>

# Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>

-   Nothing important


<a id="org87b30d1"></a>

# Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>

-   Initial release
