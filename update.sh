if [[ ! -d ./themes/anzhiyu-bkp ]]; then
    mv ./themes/anzhiyu ./themes/anzhiyu-bkp
    echo "创建安知鱼主题备份"
fi
echo "更新安知鱼主题"
git clone -b main https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu
if [[ $? != 0 ]]; then
    mv ./themes/anzhiyu-bkp ./themes/anzhiyu
    echo "失败恢复安知鱼主题备份"
fi
npm update
