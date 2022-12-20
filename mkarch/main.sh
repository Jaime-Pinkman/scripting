#!/bin/bash

while getopts ":d:n:" opt; do
  case $opt in
    d) dir_path=$OPTARG ;;
    n) name=$OPTARG ;;
    \?) echo "Invalid option: -$OPTARG" >&2 ; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1 ;;
  esac
done

if [[ -z $dir_path || -z $name ]]; then
  echo "Error: Both -d and -n parameters are required." >&2
  exit 1
fi

# Pack the directory into a tar archive and compress it with gzip
tar -czvf $name.tar.gz $dir_path

# Generate the 'name' script
echo '#!/bin/bash' > $name.sh
echo "unpackdir=." >> $name.sh
echo 'while getopts ":o:" opt; do' >> $name.sh
echo '  case $opt in' >> $name.sh
echo '    o) unpackdir=$OPTARG ;;' >> $name.sh
echo '    \?) echo "Invalid option: -$OPTARG" >&2 ; exit 1 ;;' >> $name.sh
echo '    :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1 ;;' >> $name.sh
echo '  esac' >> $name.sh
echo 'done' >> $name.sh
echo >> $name.sh
echo '# Extract the embedded archive to the specified directory' >> $name.sh
echo 'tail -n +$(($(grep -n "^__ARCHIVE_BELOW__" $0 | cut -d ":" -f 1)+1)) $0 | base64 -d | gzip -d | tar -xv -C $unpackdir' >> $name.sh
echo >> $name.sh
echo '# Exit the script' >> $name.sh
echo 'exit 0' >> $name.sh
echo >> $name.sh
echo '# The embedded archive follows this line' >> $name.sh
echo '__ARCHIVE_BELOW__' >> $name.sh

# Embed the compressed archive into the 'name' script
base64 $name.tar.gz >> $name.sh

# Set the permissions for the new script
chmod +x $name.sh
