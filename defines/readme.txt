%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IMPAN2006inGAMS package
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-------------------------------------------------------------------------------------------------------------------------
In a nutshell:

	Call build.bat to build a benchmark data set from the individual IMPLAN state data files. 

	Call run.bat 
	(i)  for aggregation of regions, sectors, factors of production, and government and household institutions
	(ii) and to verify benchmark consistency with the model soe_mcp

	Detailed information can be found in IMPLAN2006inGAMS.pdf
-------------------------------------------------------------------------------------------------------------------------

GAMS source code for dataset and model management, and some template applications are provided with the distribution directory. 
The package is designed to operate with a complete national package, consisting of social accounting matricies for each of the 50 states. 
The IMPLAN datafiles are not included in the tools archive. They may be obtained from Minnesota IMPLAN Group (see www.implan.com). 

Here are the steps involved in installing IMPLAN2006inGAMS:

	1. Create an empty root directory named, say, IMPLAN2006inGAMS.
        2. Unzip IMPLAN2006inGAMS.zip in the root directory. The root directory should have the following subdirectories:
  		
		-- BUILD This directory contains a number of GAMS programs for reading IMPLAN datafiles, and for filtering, balancing and aggregation of the dataset.
                -- DATA  This directory intends to hold all data (except for the original IMPLAN data files) in the GAMS Data eXchange (GDX) format. A number of subdirectories are created during different stages of dataset management process to hold temporary and final datasets.
    		-- DEFINES This directory contains set and mapping files which define model aggregation with respect to regions, sectors, factors of production and institutions. When aggregating a dataset, a \texttt{.set} file defines target sets and  a \texttt{.map} file defines the mapping from source to target sets.
     		-- IMPLANDATA The source IMPLAN data files have to be placed in this directory. These can be individually zipped or flat \texttt{.gms} files. To be compatible with the programs provided here, the IMPLAN data files should be named in the following way:\, \texttt{st\%year\%-\%state\%.*}\,, where \%year\% stands for the last two digits of the base year (e.g., ``06'' if 2006) and \%state\% stands for the standard two-character abbreviation for states. We have appended the year of the IMPLAN source data in order to permit comparison of model results across alternative base year datasets.
		-- LISTINGS This directory holds all listing \texttt{.lst} files that are generated during the data management process.
		-- MODELS This directory contains model source code and a few template applications.

	3. Place the source state data files in the IMPLANDATA directory and run build.bat.
 	4. Solve the sample models. The steps involved in testing the installation are in the MODEL subdirectory. See run.bat.
 

Here is an overview of the files provided in the IMPLAN2006inGAMS distribution:

ROOT DIRECTORY
	-- build.bat Master batch file controlling the conversion of IMPLAN state-level data files into GAMS-compatible data files.
	   This program calls readstate.bat and merge.gms.
	-- readstate.bat Batch file called by build.bat to read single state files and translate data into GTAP-style name space.
	   In its default operation, this program calls readall.gms and trnsl8.gms. Optionally, the model implan_acc.gms may be run to
	   verify the accounting identities implicit in the IMPLAN dataset.
	-- run.bat Batch file to run aggregation routine, balance domestic trade flows and verify benchmark consistency with a template model.
	   In its default operation, this program calls aggregation.gms, tradeadj.gms and soe_mcp.

BUILD
	-- readall.gms Reads a single IMPLAN state data file and stores the data in a .gdx file. In its default operation, this program 
	   diagonalizes IMPLAN data by converting the production structure into a commodity rather than industry basis to produce a more
	   compact and numerically stable GE model. This feature can be deactivated by setting . In addition, this program uses the GAMS 
	   routine domain.gms for efficient domain extraction.
	-- trnsl8.gms The purpose of this program is (i) to translate the IMPLAN data into GTAP-style data structures (ii) to filter the data 
	   and recalibrate the resulting dataset. The filter tolerance can be set by the parameter tol.
	
	   Filtering is important because the presence of large numbers of small coefficients in the source data can cause numerical problems. 
	   These coefficients portray economic flows which are a %negligible share of overall economic activity, yet they impose a significant
	   computational burden during matrix factorization.
	
	-- merge.gms Merges single state data files into one file.
	-- aggregation.gms Aggregates an IMPLAN dataset.
	-- tradeadj.gms Performs adjustments of trade flows so that intra-state exports and imports balance.

MODELS
	-- implan_acc.gms A static state-level model that serves to illustrate the accounting identities implicit in the IMPLAN dataset.
	-- soe_mcp.gms A prototype SOE regional US model to verify benchmark consistency. This version of the model is formulated in GAMS/MCP.
	-- soe_mge.gms A prototype SOE regional US model to verify benchmark consistency. This version of the model is formulated in GAMS/MPSGE.
