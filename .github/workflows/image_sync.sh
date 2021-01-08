TARGET_PREFIX=$1

echo "docker login as tacouser"

# MANIFEST=lma/output/hanu-deploy-apps/lma-manifest.yaml

for MANIFEST in `find | grep output/hanu-deploy-apps/`
do
    echo image sync on $MANIFEST
    sed -i '1 i\---' $MANIFEST

    for iname in ` .github/workflows/get-used-images.sh $MANIFEST`
    do
        siname=${iname//\"}
        tiname=$TARGET_PREFIX/$(echo $siname | awk -F \/ '{print $NF}')
        # echo "image=$siname, targe=$tiname"
        docker pull $siname
        docker tag $siname $tiname
        # docker push $tiname
        echo $tiname
    done 
done