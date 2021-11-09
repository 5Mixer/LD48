let project = new Project('LD48');

project.addSources('Sources');
project.addSources('Libraries/nape/haxelib/');
project.addLibrary('hxNoise');
project.addAssets('Assets')

resolve(project);
