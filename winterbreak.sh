#!/bin/sh
mount_dir="/run/media/$USER/Kindle"

echo "Waiting for Kindle to be plugged in..."
while :; do
  if [ -d "$mount_dir" ] && mountpoint -q "$mount_dir" 2>/dev/null; then
    echo "Kindle plugged in!"
    break
  fi
  sleep 1
done

# --- STEP 1 ---
if [ -f "$mount_dir/.Setup1Complete" ]; then
  curl -L -o "$mount_dir/Update_hotfix_universal.bin" \
    "https://github.com/KindleModding/Hotfix/releases/latest/download/Update_hotfix_universal.bin"

  cp -f Update_hotfix_universal.bin "$mount_dir/"
  rm -f "$mount_dir/.Setup1Complete"
  touch "$mount_dir/.Setup2Complete"

  echo "All done installing hotfix! Check the guide!"
  exit 0
fi

# --- STEP 2 ---
if [ -f "$mount_dir/.Setup2Complete" ]; then
  rm -f "$mount_dir/.Setup2Complete"
  rmdir "$mount_dir/.active_content_sandbox" 2>/dev/null

  curl -L -o "$mount_dir/PEKI.zip" \
    "https://github.com/KindleTweaks/PEKI/releases/latest/download/PEKI.zip"

  unzip -o "$mount_dir/PEKI.zip" -d "$mount_dir/documents/"

  printf "Is your kindle firmware 5.16.3 or higher? (y/n): "
  read ans

  case "$ans" in
    y|Y)
      curl -L -o kual-mrinstaller-khf.zip \
        "https://kindlemodding.org/jailbreaking/post-jailbreak/installing-kual-mrpi/kual-mrinstaller-khf.zip"
      unzip -o kual-mrinstaller-khf.zip

      cd kual-mrinstaller-khf || exit 1
      cp -a . "$mount_dir"
      ;;
    n|N)
      curl -L -o kual-mrinstaller-old.zip \
        "https://kindlemodding.org/jailbreaking/post-jailbreak/installing-kual-mrpi/kual-mrinstaller-1.7.N-r19303.zip"
      unzip -o kual-mrinstaller-old.zip

      cd kual-mrinstaller-1.7.N-r19303 || exit 1
      cp -a . "$mount_dir"
      ;;
    *)
      echo "Please respond with y or n"
      ;;
  esac

  curl -L -o renameotabin.zip \
    "https://kindlemodding.org/jailbreaking/post-jailbreak/renameotabin.zip"
  unzip -o renameotabin.zip
  cp -f renameotabin "$mount_dir/extensions/"

  exit 0
fi

# --- WINTERBREAK / FINAL ---
printf "Proceed? (y/n): "
read ans

case "$ans" in
  y|Y)
    rm -f update.bin.tmp.partial
    rm -f -- *.bin

    curl -L -o WinterBreak.tar.gz \
      "https://github.com/KindleModding/WinterBreak/releases/download/latest/WinterBreak.tar.gz"
    tar -xzf WinterBreak.tar.gz

    cd WinterBreak || exit 1
    cp -a . "$mount_dir"
    cd .. || exit 1

    touch "$mount_dir/.Setup1Complete"
    echo "All done! Please check the guide for further instuctions!"
    ;;
  n|N)
    echo "Sorry to see you go!"
    ;;
  *)
    echo "Please respond with Y or N"
    ;;
esac
