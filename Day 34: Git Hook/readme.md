### Git Post-Update Hook: Automatic Release Tag

This guide sets up a `post-update` hook in the bare repository `/opt/blog.git` so that whenever the `master` branch is updated, a release tag `release-YYYY-MM-DD` is automatically created.

---

#### Steps

```bash

# 0. Ssh into the storage server 
ssh natasha@ststor01

# 1. Navigate to the bare repository hooks directory
cd /opt/blog.git/hooks

# 2. Create the post-update hook from sample (or new file)
cp post-update.sample post-update

# 3. Replace content with this script
cat > post-update << 'EOF'
#!/bin/sh
# post-update hook: always create today's release tag for master

DATE=$(date +%F)

# Check if master branch changed
CHANGED_MASTER=0
for ref in "$@"
do
    if echo "$ref" | grep -q "refs/heads/master"; then
        CHANGED_MASTER=1
        break
    fi
done

# If master changed or stdin is empty, attempt to create tag
if [ $CHANGED_MASTER -eq 1 ] || [ -z "$@" ]; then
    echo "Creating release tag for $DATE..."
    if ! git rev-parse "release-$DATE" >/dev/null 2>&1; then
        git tag -a "release-$DATE" -m "Release for $DATE"
    else
        echo "Tag release-$DATE already exists"
    fi
fi
EOF

# 4. Make the hook executable
chmod +x post-update

# 5. In your working clone, merge feature into master
cd /usr/src/kodekloudrepos/blog
git checkout master
git merge --no-ff feature -m "Merge feature into master"

## 5.1. configure user and email accordingly
git config --global user.name natasha
git config --global user.email natasha@ststor01.stratos.xfusioncorp.com

# 6. Push master to the bare repository to trigger the hook
git push origin master

# 7. Fetch tags in your clone and verify
git fetch --tags
git tag
git show release-$(date +%F)

# 8. Optional: make a dummy commit to force hook execution
touch trigger_hook.txt
git add trigger_hook.txt
git commit -m "Trigger post-update hook"
git push origin master
