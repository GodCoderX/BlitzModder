project=$(grep APPLICATION_NAME Makefile | awk '{print $3}')
echo "Packaging: $project"

target=".theos/_/DEBIAN/postinst"
cp sudoapp.template $target
#perl -p -i -e "s,BlitzModder,$project,g" $target
chmod 0555 $target
