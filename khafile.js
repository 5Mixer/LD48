let project = new Project('Marblerun');

project.addSources('Sources');
project.addLibrary('nape');
project.addLibrary('hxNoise');
project.addAssets('Assets')

resolve(project);
