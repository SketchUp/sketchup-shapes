# SketchUp Shapes Extension


SketchUp Shapes allows users to quickly creates 3D shape objects by specifying a few attributes.  The objects created by the shapes extension are parametric so they can be edited after creation.  This extension is an Open Source project and can be improved by anyone.


## Installing

The latest and greatest is available as an RBZ file from Extension Warehouse. 

Generally, the best way to install an extension is to open Extension Warehouse from inside SketchUp, searching for  "shapes" and then click the Install button (You need to be signed in to download).  Installing via SketchUp will automatically download, unpack and place the files in the appropriate locations.  

If you need to download from outside SketchUp, follow this url - http://extensions.sketchup.com/content/shapes.

Then open SketchUp and select `Window → Preferences` (Microsoft Windows) or `SketchUp → Preferences` (Mac OS X) `→ Extensions → Install Extension` and select the RBZ file you just downloaded. Voila! SketchUp installs the extension. 

For development installations you will need to copy the contents of the `src` folder from this project, into your sketchUp plugins folder.


## Contributing

### Members

If you're an owner of this repository, here are some steps.

Get a local copy of the files. This will create a sketchup-stl folder.

    git clone https://github.com/SketchUp/shapes.git  
    cd shapes  

Use your favorite editor to edit README.md. Then...

    git add README.md                     // Marks README.md for edit.  
    git commit -m "Editing our README"    // Records changes in the local branch.  
    git push                              // Submits to repository. Yay!  

### Community 

If you're a SketchUp Ruby community member, you need to fork this repository (If you don't know what that is, that's okay, we barely know ourselves. Go google some GitHub tutorials and give it a try. Please improve our README.md file with better instructions!)

#### Steps

1. Fork this repository ([tutorial](https://help.github.com/articles/fork-a-repo)). Forking will create a copy of this repository under your GitHub username.

1. Clone a local copy of your fork to your compuater. For this you will need git installed on your personal computer. [SourceTree](http://www.sourcetreeapp.com/) is a good choice. It will let you perform most git tasks via a GUI.

1. Add this repository as a remote so you can pull in updates to your clone.

        git remote add upstream https://github.com/SketchUp/sketchup-stl.git

1. Make your changes to the code in your cloned repository, then commit. (`git commit ...`)

1. Push your changes to your GitHub repository.  (`git push`)

1. From your GitHub repository, send a Pull Request.


## License

See the LICENSE and NOTICE files for more information

Copyright 2014 Trimble Navigation Ltd.

License: The MIT License (MIT)
