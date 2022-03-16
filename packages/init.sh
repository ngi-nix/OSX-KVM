set -e
if [ -e disk0.qcow2 ]; then
  echo "The current directory already contains disk0.qcow2. Delete it first!"
  exit 1
fi

# get settings from user input
echo "choose disk size (example: 64G)" && echo -n "answer: "
read diskSize
echo "choose ram size (example: 6G)" && echo -n "answer: "
read ramSize
echo "choose number of cpu cores (example: 2)" && echo -n "answer: "
read cores
echo "choose MacOS version (example: 10.15) (leave empty for latest)" && echo -n "answer: "
read osVersion

echo "{}" > settings.json
jq ".ramSize = \"$ramSize\"" settings.json | sponge settings.json
jq ".cores = \"$cores\"" settings.json | sponge settings.json
jq ".headless = \"false\"" settings.json | sponge settings.json

if [ "$osVersion" == "" ]; then
  fetchMacOS
else
  fetchMacOS -v $osVersion
fi
dmg2img ./BaseSystem/BaseSystem.dmg ./BaseSystem.img
rm -r ./BaseSystem

qemu-img create -f qcow2 disk0.qcow2 $diskSize
