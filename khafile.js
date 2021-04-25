let project = new Project('LD48');

project.addSources('Sources');
project.addLibrary('nape');
project.addLibrary('hxNoise');
project.addAssets('Assets')

resolve(project);
