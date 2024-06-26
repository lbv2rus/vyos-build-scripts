# vyos-build-scripts
Some my bash scripts to build vyos image and its packages from source

# What you need for build
1. Debian Virtual or Hardware Machine (Debian 10 for VyOs 1.3 and Debian 12 for VyOs 1.4). (I don`t like Docker, but you can adopt this to run in docker.)
2. LocalHost or Remote Web-Server, that will host your Private Repo of Vyos Packages. (Some instructions you can find here https://habr.com/ru/articles/543854/)

# Build Instructions
1. First clone Vyos-Build Repo (Uncomment relevant lines in vyos_build.sh Scripts)
2. Run Prereq Install (Uncomment relevant lines in vyos_build.sh Scripts)
4. Make Kernel and Kernel Firmware by running vyos_build.sh and answer Y to Kernel Build Promt.
5. Uncomment Packages files (for first-time build one at a time) and run vyos_build.sh
6. When all packages are created answer Y to Repository Update.
7. For 1.4 run Prereq Install one more time before ISO Build.
