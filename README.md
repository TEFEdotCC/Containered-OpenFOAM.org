# OpenFOAM Docker image

An OpenFOAM image which is mainly designed to execute openfoam jobs.

# Build

Execute the script `hooks/build`.

# Usage

Executing an OpenFOAM case from the current directory:
```bash
cd path/to/case/dir
docker run -it --rm -v $PWD:/data tefe/openfoam.org:dev ./Allrun   
```

Get a bash with all containg OpenFOAM commands:
```bash
docker run -it --rm -v $PWD:/data tefe/openfoam.org:dev bash    
```

**Notice**

You can change ```$PWD``` to any directory or environment variable that contains the OpenFOAM case files.

