Towerbot = require('../index');
towerbot = new Towerbot(['test/towerbot.yml', 'test/custom.yml']);

#text = "sync geb prod"
#text = "sync the  geb  to qa 1120 asdf adsf asf asdf "
#text = "release patch geb prod"
text = "test2  a this to command on prod sdfasf asdf adsf asf asdf "
console.log("Text", text)
towerbot.chat = {}

job = towerbot.getCommand(text, 1).result
console.log("Result: ", job)

towerbot.launchTowerJob(
	job,
	"confirmation=y",
	":sunglasses: Ok cool!. "
)
