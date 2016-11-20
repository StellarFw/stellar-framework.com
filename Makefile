all:
	rm -rf public db.json
	hexo generate
	hexo deploy
