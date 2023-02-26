# plex-amd - Docker mod for Plex

This mod adds the mesa libraries (v20.1+) needed for hardware encoding (VAAPI) on AMD GPUs to the Plex Docker container (`latest` tag).

To enable, you need to add the 2 following entries:
- Device mapping for `/dev/dri`
  - docker-compose: 
    ```yaml
        devices:
          - /dev/dri:/dev/dri
    ```
  - docker cli
    ```sh
    --device /dev/dri:/dev/dri
    ```
- Environment Variable: `DOCKER_MODS=linuxserver/mods:plex-amd`
  - docker-compose:
    ```yaml
        environment:
          - DOCKER_MODS=linuxserver/mods:plex-amd
    ```
  - docker cli:
    ```sh
    -e DOCKER_MODS=linuxserver/mods:plex-amd
    ```

If adding multiple mods, enter them in an array separated by `|`, such as `DOCKER_MODS=linuxserver/mods:plex-amd|linuxserver/mods:plex-mod2`

## Settings in Plex
Under server administration in `Server > Settings > Transcoder` the `Hardware acceleration` can be enabled by checking the `Use hardware acceleration when available`.
If you are also creating optimized versions, you can enable `Use hardware-accelerated video encoding` too. 
![image](https://user-images.githubusercontent.com/14975046/221403407-d1f829c1-ad23-4a7c-8872-a040c3c71294.png)
