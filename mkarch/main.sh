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
echo '#!/bin/bash' > $name
echo "unpackdir=." >> $name
echo 'while getopts ":o:" opt; do' >> $name
echo '  case $opt in' >> $name
echo '    o) unpackdir=$OPTARG ;;' >> $name
echo '    \?) echo "Invalid option: -$OPTARG" >&2 ; exit 1 ;;' >> $name
echo '    :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1 ;;' >> $name
echo '  esac' >> $name
echo 'done' >> $name
echo >> $name
echo '# Extract the embedded archive to the specified directory' >> $name
echo 'tail -n +$(($(grep -n "^__ARCHIVE_BELOW__" $0 | cut -d ":" -f 1)+1)) $0 | base64 -d | gzip -d | tar -xv -C $unpackdir' >> $name
echo >> $name
echo '# Exit the script' >> $name
echo 'exit 0' >> $name
echo >> $name
echo '# The embedded archive follows this line' >> $name
echo '__ARCHIVE_BELOW__' >> $name

# Embed the compressed archive into the 'name' script
base64 $name.tar.gz >> $name

# Remove the compressed archive
rm $name.tar.gz

# Set the permissions for the new script
chmod +x $name
