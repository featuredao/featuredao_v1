const fs = require('fs');

module.exports = async function (jsonInfo) {

  const string = JSON.stringify(jsonInfo, '', '  ');
  const file = './build/info.js';
  const fd = fs.openSync(file, 'w+');

  fs.writeFileSync(fd, `module.exports = ${string}`, {
    encoding: "utf8",
  });
};
