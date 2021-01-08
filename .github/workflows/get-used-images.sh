if [ $# -ne 1 ]; then
 echo "Usage: $0 TACO-app-manifest-file"
 exit -1
fi

# TMP=/tmp/image-sync
# mkdir /tmp/image-sync

awk ' /^---/{
  close(file)
  file=NR".split.yaml"
};
{print >file}' $1

for i in `ls *.split.yaml`
do
    .github/workflows/helm-template.py $i > template.sh
    chmod 755 template.sh
    
    ./template.sh | grep image: | awk -F image:\  '{print $2}'
done

rm *.split.yaml
rm *.split.yaml.vo

