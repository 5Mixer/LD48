let project = new Project('LD48');

project.addSources('Sources');
project.addSources('Libraries/nape/haxelib/');
project.addShaders('Shaders')
project.addLibrary('hxNoise');
project.addAssets('Assets')

project.addDefine("NAPE_RELEASE_BUILD")

resolve(project);
