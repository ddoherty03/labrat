- [Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>](#org0072ea7)
- [Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>](#org309b509)
- [Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>](#orgcd48f5d)
- [Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>](#orgd671ebe)
- [Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>](#org55a1d4d)
- [Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>](#org89e5245)
- [Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>](#orgeed739d)
- [Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>](#orgadd5092)
- [Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>](#org25c7986)
- [Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>](#org2d49d11)


<a id="org0072ea7"></a>

# Version 1.6.0 <span class="timestamp-wrapper"><span class="timestamp">[2026-03-06 Fri]</span></span>

-   Improved labrat.el to ensure that the **labrat** buffer gets created and logs the command used along with a timestamp and any errors.
-   Echo the output file name after creation.
-   Add the process number to file name to prevent name collisions.
-   Fix use of XDG\_DATA\_HOME environment variable.


<a id="org309b509"></a>

# Version 1.4.1 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-28 Sun]</span></span>

-   Added a `vim` plugin to allow printing or viewing labels from within a vim buffer as was possible in Emacs with `labrat.el`.


<a id="orgcd48f5d"></a>

# Version 1.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-26 Fri]</span></span>

-   By default, labrat no longer puts the output file in labrat.pdf; instead, all labels go to `~/.local/share/labrat` and uses the run time for a time-stamp file name.
-   Output file can still be overridden with the `-o` or `--out-file` option


<a id="orgd671ebe"></a>

# Version 1.2.3 <span class="timestamp-wrapper"><span class="timestamp">[2025-03-20 Thu]</span></span>

-   No user-visible changes


<a id="org55a1d4d"></a>

# Version 1.2.2 <span class="timestamp-wrapper"><span class="timestamp">[2024-11-29 Fri]</span></span>

-   Used `fat_config` gem to read config files


<a id="org89e5245"></a>

# Version 1.2.1 <span class="timestamp-wrapper"><span class="timestamp">[2024-09-20 Fri]</span></span>

-   Fixed `labrat.el` view command


<a id="orgeed739d"></a>

# Version 1.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-19 Thu]</span></span>

-   Changed `nl-sep` to '~~'
-   Changed `label-sep` to '@@'
-   Minor bug fixes


<a id="orgadd5092"></a>

# Version 1.1.0 <span class="timestamp-wrapper"><span class="timestamp">[2023-01-06 Fri]</span></span>

-   Changed `nl-sep` to '&#x2013;>'
-   Changed `label-sep` to '==>'
-   Added label name to template output


<a id="org25c7986"></a>

# Version 0.1.14 <span class="timestamp-wrapper"><span class="timestamp">[2022-02-03 Thu]</span></span>

-   Nothing important


<a id="org2d49d11"></a>

# Version 0.1.13 <span class="timestamp-wrapper"><span class="timestamp">[2021-11-04 Thu]</span></span>

-   Initial release
