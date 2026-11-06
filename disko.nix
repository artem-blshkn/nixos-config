{
  # ОДИН диск, Windows стирается. disko пересоздаёт GPT целиком.
  #
  # Итоговая раскладка:
  #   nvme0n1p1  2G   vfat  /boot      ESP (только UKI, без секретов)
  #   nvme0n1p2  rest LUKS  cryptroot
  #     └─ LVM VG "pool"
  #          ├─ swap 32G  [SWAP]       образ гибернации
  #          └─ root ~204G btrfs       @ / @home @nix @var @snapshots
  #
  # 32G swap = размер RAM (2×16 ГБ): образ сжимается, но несжимаемые данные
  # дают почти полный размер RAM. Меньше — гибернация может отказать.
  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1"; # проверить: lsblk
      type = "disk";

      content = {
        type = "gpt";

        partitions = {
          # 2G: lanzaboote кладёт сюда UKI (~60–100 МБ каждый),
          # 4 поколения + запас.
          ESP = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true; # TRIM для SSD сквозь LUKS
              };
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "32G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true; # disko сам выставит boot.resumeDevice
          };
        };

        root = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-K" ]; # -K: не делать TRIM при mkfs (на VDI/медленных SSD это зависает)
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" "space_cache=v2" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
              };
              "@var" = {
                mountpoint = "/var";
                mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
              };
              "@snapshots" = {
                mountpoint = "/.snapshots";
                mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
              };
            };
          };
        };
      };
    };
  };
}
