# vyos-build-scripts
Some my bash scripts to build VyOS image and its packages from source.

# What do you need for build
1. Debian Virtual or Hardware Machine (Debian 10 for VyOS 1.3 (equuleus) and Debian 12 for VyOS 1.4 (sagitta)). (I don`t like Docker, but you can adopt this to run in docker.)
2. Localhost or Remote Web-Server, that will host your Private Repo of VyOS Packages. (Some instructions in English you can find here https://habr.com/ru/articles/543854/)

# Build Instructions
1. First clone Vyos-Build Repo (Uncomment relevant lines in vyos_build.sh Script).
2. Run Prerequisites Install (Uncomment relevant lines in vyos_build.sh Script).
4. Build Kernel and Kernel Firmware by running vyos_build.sh and answer Y to Kernel Build Prompt.
5. Uncomment Packages files (for first-time build one at a time) and run vyos_build.sh Script.
6. When all packages are created answer Y to Repository Update Prompt.
7. For VyOS 1.4 (sagitta) run Prerequisites Install one more time before ISO Build.
8. Run ISO Build with answer Y to ISO Build Prompt.

# Information
1. Build-time for all packages and Kernel is around 3 hours.
2. You can build packages in any direction, but with attention to dependencies and build results.
3. You must have in your Repository only one instance of package, except Kernel. Delete old package manually before build new one.

