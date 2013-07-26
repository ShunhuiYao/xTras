MakeAnsatz::usage = "MakeAnsatz[list] makes an Ansatz. \
The Ansatz is a sum of the contractions multiplied with arbitrary constant symbols.\n\
MakeAnsatz[expr, ConstantPrefix -> \"prefix\"] gives the constant symbols the given prefix.";

MakeContractionAnsatz::usage =
	"MakeContractionAnsatz[expr] makes an Ansatz with all possible contractions of expr. \n\
MakeContractionAnsatz is a convenience wrapper for AllContractions and MakeAnsatz.";

ConstantPrefix::usage = "ConstantPrefix is an option for MakeAnsatz.";

SymmetrizeMethod::usage =
	"SymmetrizeMethod is an option for AllContractions. Its values can be \
'ImposeSymmetry' (default), 'ImposeSym', or 'None'. The first uses xTensor's explicit \
symmetrization to symmetrize the free indices, whereas the second uses \
SymManipulator's implicit ImposeSym to symmetrize the free indices. 'None' does not \
symmetrize the free indices, but instead keeps auxiliary tensor (see also the option \
AuxiliaryTensor).";

UncontractedIndices::usage = 
	"UncontractedIndices is an option for AllContractions which specifies how \
many index pairs should not be contracted. The default is None, which amounts to \
contracting all indices. It can also be an integer in the range from 0 to the number \
total indices. \n\
Note that when not all indices are contracted, AllContractions returns a \
list containing one element per contraction, not taking the ordering of \
the free indices into account.";

AuxiliaryTensor::usage =
	"AuxiliaryTensor is an option for AllContractions. It can be used to specify the name \
of the auxiliary tensor used for the free indices.";

FreeMetrics::usage =
	"FreeMetrics is an option for AllContractions.";

AllContractions::usage =
	"AllContractions[\!\(\*\nStyleBox[\"expr\", \"TI\"]\)] returns a sorted list of all possible \
full contractions of \!\(\*\nStyleBox[\"expr\", \"TI\"]\) over its free indices.\n\
AllContractions[\!\(\*\nStyleBox[\"expr\", \"TI\"]\), \!\(\*\nStyleBox[\"frees\", \"TI\"]\)] \
returns all possible contractions of \!\(\*\nStyleBox[\"expr\", \"TI\"]\) that have \
\!\(\*\nStyleBox[\"frees\", \"TI\"]\) as free indices.\n\
AllContractions[\!\(\*\nStyleBox[\"expr\", \"TI\"]\), \!\(\*\nStyleBox[\"frees\", \"TI\"]\), \!\(\*\nStyleBox[\"sym\", \"TI\"]\)] \
returns all possible contractions of \!\(\*\nStyleBox[\"expr\", \"TI\"]\) with the symmetry \
\!\(\*\nStyleBox[\"sym\", \"TI\"]\) imposed on the free indices \!\(\*\nStyleBox[\"frees\", \"TI\"]\)."

MakeTraceless::usage =
	"MakeTraceless[expr] returns the traceless version of expr, if any.";

MakeTraceless::unfixed = "Setting unfixed parameters to zero.";

MakeTraceless::notunique = "More than one traceless solution, returning all.";

IndexConfigurations::usage =
	"IndexConfigurations[expr] gives a list of all independent index configurations of expr.";



(* Young tableaux *)

YoungTableauQ::usage = 
  "YoungTableauQ[tableau] returns True if tableau is a proper Young \
tableau, and False otherwhise. A proper Young tableau is a list of \
lists of integers or symbols, whose intersection is empty. \
Furthermore the length of the lists has to decrease monotonically.";

ManifestSymmetry::usage =
	"ManifestSymmetry is an option for YoungSymmetrize, YoungProject, and TableauSymmetric that specifies \
with what convention the Young diagram is symmetrized. \n
The default is \
Antisymmetric, with which first the rows of the diagram are symmetrized \
and lastly the columns antisymmetrized, resulting in an expression with manifest
column antisymmetry.\n
The other setting is Symmetric, with which first the columns are antisymmetrized \
and lastly the rows are symmetrized, resulting in an expression with manifest \
row symmetry.";

YoungSymmetrize::usage = 
  "YoungSymmetrize[expr,tableau] symmetrizes a tensorial expression \
according to tableau, where the entries of the tableau have to be the \
set of free indices of expr.\n
  YoungSymmetrize[tensor,tableau] symmetrizes the tensor (withouth \
the [] on tensor) according to tableau, where the entries of tableau \
are integers.\n
See also the option ManifestSymmetry.";

YoungProject::usage = 
  "YoungProject[expr,tableau] projects a tensorial expression onto \
tableau, where the entries of the tableau have to be the set of free \
indices of expr. \nYoungProject[tensor,tableau] projects the tensor \
(withouth the [] on tensor) onto tableau, where the entries of \
tableau are integers. \n\nThe difference between projecting and \
symmetrizing is that the projection has a different overall factor, \
such that repeatedly projecting does not change the result.\n
See also the option ManifestSymmetry.";

RiemannYoungRule::usage = 
  "RiemannYoungRule[CD,n] gives the projection rule of n'th covariant \
derivative of the Riemann tensor of the covariant derivative CD onto \
its Young tableau. n has the default levelspec form. The default for n is {0}.";

RiemannYoungProject::usage = "\
RiemannYoungProject[expr] projects all Riemann tensors in expr onto their Young tableau.\n\
RiemannYoungProject[expr, n] projects also n-fold covariant derivatives of the Riemann tensor.\n\
RiemannYoungProject[expr, cd, n] only projects Riemann tensors of the covariant derivative cd.";

TableauSymmetric::usage =
	"TableauSymmetric[tableau] gives the Strong Generating Set in Cycles notation of the \
mono-term symmetry of the given tableau. It takes the option ManifestSymmetry.";

TableauDimension::usage =
	"TableauDimension[tableau] gives the dimensions of the given tableau.";

BasicDDI::usage = 
	"BasicDDI is a reserved word in xTras`Combinatorics`. It is used to label the various \
dimensional dependent identities.";

BasicDDIDefQ::usage = 
	"BasicDDIDefQ[covd] returns True if the basic DDI has been defined for the given covariant \
derivative, and False otherwise.";

BasicDDIRelations::usage =
	"BasicDDIRelations[covd] gives the relation of the basic DDI of the given covariant derivative \ 
to metrics.";

BasicDDITableaux::usage =
	"BasicDDITableaux[covd] stores the standard Young tableaux of the associated basic DDI.";

ConstructDDIs::usage =
	"ConstructDDIs[expr, indices, symmetry] constructs all DDIs with the tensor structure of expr. \
It returns a list of tensorial expressions that are zero due to over-antisymmetrization.";


Begin["`Private`"]


(* DeleteDuplicateFactors is similiar to Union, except that it removes any overall integer or
   rational factor, and throws away zeros. *)
(* Main driver over lists. *)
DeleteDuplicateFactors[list_List] := Union[DeleteDuplicateFactors1 /@ list];
(* Over single entries. Throw away zeros. *)
DeleteDuplicateFactors1[0] = Sequence[];
(* Remove overall integer and rational factors. *)
(* Over sums: sort by the non-(integer/rational) parts of the sum, and remove the first overall factor. *)
DeleteDuplicateFactors1[sum_Plus] := #/First@First@SortBy[DeleteDuplicateFactors2/@List@@sum,Last]&/@sum
(* Over non-sums: *)
DeleteDuplicateFactors1[x_] := Last@DeleteDuplicateFactors2@x;
(* Helper function. *)
DeleteDuplicateFactors2[product:Times[constant_?ConstantQ, x__]] := {constant,Times[x]}
DeleteDuplicateFactors2[x_] := {1,x};


Options[MakeAnsatz] ^= {
	ConstantPrefix -> "C"
};

MakeAnsatz[list_List, options___?OptionQ] := 
	Dot[
		list,
		DefNiceConstantSymbol[
			ConstantPrefix /. CheckOptions[options] /. Options[MakeAnsatz],
			#
		]& /@ Range@Length@list
	];

MakeContractionAnsatz[args__, options___?OptionQ] := MakeAnsatz[AllContractions[args, options],options];



(**************************************)
(* Metric contractions & permutations *)
(**************************************)


Options[MakeTraceless] ^= {Verbose -> False};

MakeTraceless[expr_, options___?OptionQ] := Module[
	{
		sym = SymmetryOf[expr],
		frees, sgs, auxT, VB, M, metric,
		contractions, ansatz, ansatzExpanded, constants, c, sols, result, verbose, map,
		metrics, singlecontractions, uniquemetrics
	},
	
	frees = Last /@ sym[[3]];
	sgs = sym[[4]];
	
	If[Length@frees < 2,
		Throw@Message[MakeTraceless::error, "Cannot make traceless."];
	];
	
	verbose = Verbose /. CheckOptions[options] /. Options[MakeTraceless];
	If[TrueQ[verbose],
		map = MapTimed,
		map = Map[#1,#2]&
	];

	(* Init geometric variables. *)
	VB 		= VBundleOfIndex@First@frees;
	M 		= BaseOfVBundle@VB;
	metric 	= First@MetricsOfVBundle@VB;
	
	(* 
	   Determine the independent single contractions of expr.
	   To this end we first define a new auxiliary tensor,
	   because we're interested in the symmetry structure of expr,
	   and not in possible downvalues its contractions might have.
	 *)
	Block[{$DefInfoQ=False},DefTensor[auxT @@ frees, M, sgs]];
	(* Get the possibly dependent metrics that form all single contractions. *)
	metrics 			= metric @@ (ChangeIndex /@ #) & /@ Subsets[frees, {2}];
	(* The single contractions are then ... *)
	singlecontractions 	= SameDummies@Map[
		ChangeFreeIndices[#, frees[[1 ;; -3]]] &,
		ToCanonical@ContractMetric[metrics * (auxT @@ frees)]
	];
	(* The independent metrics that form all unique single contractions are then ... *)
	uniquemetrics = Function[
		x, 
		First@First@Select[Transpose[{metrics, singlecontractions}], MatchQ[Last@#, -x | x ] &, 1]
	] /@ DeleteDuplicateFactors[singlecontractions];
	(* And undefine the auxiliary tensor. *)
	Block[{$UndefInfoQ=False},UndefTensor[auxT]];
	
	(* 
	    The actual meat of the algorithm: getting all possible traces with the correct
	    symmetry. For this, AllContractions comes in very very handy here. 
	 *)
	contractions = AllContractions[
		expr,
		IndexList@@frees,
		sgs,
		SymmetrizeMethod -> ImposeSym,
		UncontractedIndices -> None,
		FreeMetrics -> {1, Infinity}, (* This is for not getting completely uncontracted traces, of which we only want the original expr *)
		Verbose -> verbose
	];
	
	(* Define constant symbols for the Ansatz. *)
	constants = SymbolJoin[c,#]& /@ Range@Length@contractions;
	Block[{$DefInfoQ=False},DefConstantSymbol /@ constants];
	(* Make the Ansatz. *)
	ansatz 			= expr + constants.contractions;
	ansatzExpanded 	= expr + constants.map[
		ExpandSym[#, SmartExpand -> False]&,
		contractions,
		Description -> "Expanding symmetry."
	];
	
	(* Take single contractions, and demand that they are zero. *)
	If[verbose, PrintTemporary[" ** Solving."]];Quiet[
		sols = SolveConstants[
			map[
				( ToCanonical@ContractMetric[#] == 0 )&,
				uniquemetrics * ansatzExpanded,
				Description -> "Taking single contractions."
			],
			constants
		],
		{Solve::svars}
	];
	
	(* Some logic for if there are multiple solutions etc. *)
	result = Switch[
		Length@sols,
		0,
		Throw@Message[MakeTraceless::error, "Cannot make traceless."],
		1,
		ansatz /. Simplify@First@sols,
		_,
		Message[MakeTraceless::notunique];
		ansatz /. sols
	];
	
	(* Set any unfixed constants to zero. *)
	If[!FreeQ[result, Alternatives@@constants],
		Message[MakeTraceless::unfixed];
		result = result /. (#->0 & /@ constants);
	];
	
	(* Undefine the constants used in the Ansatz. *)
	Block[{$UndefInfoQ=False},UndefConstantSymbol /@ constants ];
	
	(* Return final result. *)
	result
];


Options[AllContractions] ^= {
	Verbose -> False,
	SymmetrizeMethod -> ImposeSymmetry,
	UncontractedIndices -> None,
	FreeMetrics -> All,
	AuxiliaryTensor -> Default
};

AllContractions[expr_,options___?OptionQ] := 
	AllContractions[expr, IndexList[], options];

AllContractions[expr_,freeIndices:(IndexList|List)[___?AIndexQ],options___?OptionQ] := 
	AllContractions[expr, freeIndices, StrongGenSet[{},GenSet[]], options];

AllContractions[expr_List, freeIndices:(IndexList|List)[___?AIndexQ], symmetry_, options___?OptionQ] :=
	Apply[
		Union,
		AllContractions[#, freeIndices, symmetry, options]& /@ expr
	];

AllContractions[expr_,freeIndices:(IndexList|List)[___?AIndexQ], symmetry_, options___?OptionQ] := Module[
	{
		expl,verbose,symmethod,map,exprIndices,numIndices,VB,metric,
		auxT,auxTexpr,auxTname,indexlist,dummylist,dummies,M,removesign,process,step,
		contractions,
		sym,sgs,frees,dummysets,newdummies,newdummypairs,previousdummies,
		numContractions,uncons,
		freeMetrics, countFreeMetrics
	},

	(* Set the options. *)
	{verbose,symmethod,uncons,freeMetrics,auxTname} = 
		{Verbose, SymmetrizeMethod, UncontractedIndices, FreeMetrics, AuxiliaryTensor} 
		/. CheckOptions[options] /. Options[AllContractions];
	If[TrueQ[verbose],
		map = MapTimed,
		map = Map[#1,#2]&
	];
	If[auxTname =!= Default,
		auxT = auxTname
	];
	
	expl = FromIndexFree[expr];
	
	(* Get the indices of the complete expression (expr + freeindices), and count them.  *)
	exprIndices	= Join[IndexList@@freeIndices,IndicesOf[Free][expl]];
	numIndices 	= Length[exprIndices];
	
	If[uncons === None,
		numContractions = numIndices / 2,
		numContractions = numIndices / 2 - uncons / 2;
	];
		
	(* Do some checks *)
	If[IndicesOf[Dummy][expl] =!= IndexList[],
		Throw@Message[AllContractions::error, "Input expression cannot have dummy indices."];
	];
	If[!IntegerQ@numContractions,
		Throw@Message[AllContractions::error, "Can only contract an even number of indices."];
	];
	If[numContractions > numIndices / 2 || numContractions < 0,
		Throw@Message[AllContractions::error, "Number of contractions out of range."];
	];
	If[Length@Union[VBundleOfIndex/@exprIndices] =!= 1,
		Throw@Message[AllContractions::error, "More than one tangent bundle detected."];
	];
	If[Length@MetricsOfVBundle@VBundleOfIndex@First@exprIndices === 0,
		Throw@Message[AllContractions::error, "No metric found in tangent bundle."];
	];

	(* Init geometric variables. *)
	VB 		= VBundleOfIndex@First@exprIndices;
	M 		= BaseOfVBundle@VB;
	metric 	= First@MetricsOfVBundle@VB;
	
	(* Check if the metric is symmetric. *)
	If[xAct`xTensor`Private`SymmetryOfMetric[metric] =!= 1,
		Throw@Message[AllContractions::error, "Can't do contractions for non-symmetric metrics."];
	];
	
	(* Define an auxilary tensor if it is not already defined. 
	   We vary w.r.t. to this tensor afterwards to free the indices. *)
	If[xTensorQ[auxT],
		If[
			SymmetryGroupOfTensor[auxT] =!= (xAct`xTensor`Private`SGSofsym[symmetry] /. Thread[List@@freeIndices -> Range@Length@freeIndices])
		|| 	SlotsOfTensor[auxT] =!= (List@@freeIndices /. i_?AbstractIndexQ :> VBundleOfIndex[i])
		,
			Throw@Message[AllContractions::error, "Existing auxiliary tensor has wrong index structure and / or symmetry."];
		],
		ValidateSymbol[Evaluate@auxT];
		Block[{$DefInfoQ=False},DefTensor[auxT@@freeIndices,M,symmetry]];
	];

	(* Replace indices on the auxT (because they might overlap with expr). *)
	auxTexpr	= expl * auxT@@Table[DummyIn@VB,{Length@freeIndices}];
	(* Get the symmetry and its Strong Generating Set. *)
	sym			= SymmetryOf[auxTexpr];
	sgs			= sym[[4]];
	
	(* One more check. *)
	If[numIndices =!= First@sym,
		Throw@Message[
			AllContractions::error, 
			"Number of indices and range of symmetry doesn't match."
		];
	];
	
	
	(* Canonicalization might give a minus sign or zero. 
	   Remove both and the Images head. *)
	removesign[0] 	= Sequence[];
	removesign[-Images[perm_]] := perm;
	removesign[ Images[perm_]] := perm;

	(* The actual processing function that does all possible single contractions of a permutation. *)
	process[entry_] := Map[
		removesign@CanonicalPerm[Images[#],numIndices,sgs,frees,dummysets]&,
		NextDummyPermutations[entry,newdummies,previousdummies]
	] // Union;

	(* Initiliaze some variables for below. *)
	step 			= 1;
	contractions 	= {Range@numIndices};
	newdummypairs 	= Reverse /@ Partition[Reverse@Range@numIndices, {2}];

	(* Apply the processing function numContraction times, starting from the seed. *)
	map[(
		frees 			= Range[numIndices-2step];
		dummysets 		= {DummySet[VB,Reverse[newdummypairs[[1;;step]]],1]};
		newdummies 		= newdummypairs[[step]];
		previousdummies = Flatten@Reverse[newdummypairs[[1;;step-1]]];
		contractions 	= Union@@(map[
				process,
				contractions,
				Description -> "Contracting pair " <> ToString[step++]
			]);
		)&,
		Range[numContractions],
		Description -> StringJoin[
			"Contracting ", ToString@numContractions, 
			" pairs of indices with metric ", ToString@PrintAs[metric]
		]
	];
	
	(* Construct a list of indices. Don't include freeIndices, because they
	   will clash later when we remove the auxiliary tensor. *)
	indexlist 	= IndexList@@GetIndicesOfVBundle[VB,numIndices - numContractions,UpIndex/@freeIndices];
	dummylist	= indexlist[[-numContractions;;-1]];
	dummies		= IndexList@@Riffle[List@@dummylist,-List@@dummylist];
	indexlist	= IndexSort@Join[indexlist[[1;;numIndices-2numContractions]],dummies];
	
	(* Reconstruct tensorial expressions from the permutations. *)
	contractions = UxSort@xAct`xTensor`Private`Reconstruct[
		sym,
		{1,PermuteList[indexlist,InversePerm@Images[#]]}
	]& /@ contractions;

	(* Sometimes we can have redundant contractions (most likely from downvalues
	   on tensors in the original expression). Try to remove the signs before doing anything else. *)
	contractions = DeleteDuplicateFactors[contractions];
	
	(* Select those contractions with the wanted number of free metrics. *)
	countFreeMetrics[auxT[inds___] * ___] := 1/2 * Length@IndicesOf[Dummy][auxT[inds]];
	contractions = Select[
		contractions,
		IntervalMemberQ[
			Interval[ToLevelSpec[freeMetrics]],
			countFreeMetrics[#]
		]&
	];

	(* Now remove redundant contractions with a ToCanonical. *)
	contractions = DeleteDuplicateFactors[
		map[
			ToCanonical[#]&,
			contractions,
			Description -> "Removing duplicates."
			]
	];	
	
	(* Remove the auxiliary tensor. *)
	contractions = RemoveAuxT[contractions, auxT, freeIndices, dummylist, symmethod];
	
	(* Lastly, undefine the auxiliary tensor. We couldn't do this before
	   because we needed its symmetry in the previous step. *)
	If[FreeQ[contractions,auxT],
		Block[{$UndefInfoQ=False},UndefTensor[auxT]]
	];
	
	(* Return result. Because tensors might have up/down values, we still need to 
	   remove signs, zeros, and duplicates. *)
	DeleteDuplicateFactors[contractions] 
];

RemoveAuxT[list_List, auxT_?xTensorQ, frees_, dummies_, symmethod_] := Module[
	{
		canon = ReplaceDummies[ToCanonical@ContractMetric[#],dummies]&,
		symm
	},
	Switch[symmethod,
		(* ImposeSymmetry: impose symmetry first, and then canonalize later. *)
		ImposeSymmetry,
		symm = canon@ImposeSymmetry[#,frees,SymmetryGroupOfTensor@auxT]&,
		(* ImposeSym: canocalize first (to contract metrics generated at the previous step), then symmetrize. *)
		ImposeSym,
		symm = ImposeSym[canon[#],frees,SymmetryGroupOfTensor@auxT]&,
		_,
		Return[list];
	];
	
	symm /@ ReplaceAll[
		list,
		auxT[inds___] :> Inner[
			delta, 
			IndexList[inds], 
			IndexList@@frees, 
			Times
		]
	]	
];

(* 
 * NextDummyPermutations take a list representing an Images permutation,
 * a pair of new dummies, and a list of old dummies, and gives all possible
 * permutations of positions of the new dummies in the initial permutation
 * while leaving the old dummies alone.
 * All inputs are assumed to be lists of numbers, and previousDummies 
 * is assumed to ordered, and newDummy1 < newDummy2. 
 *)
NextDummyPermutations[perm_List, {newDummy1_,newDummy2_}, previousDummies_] := With[
	{
		positions	= Sort[{Position[perm,#][[1,1]],#}&/@previousDummies],
		subsets 	= Subsets[Range[Length@perm - Length@previousDummies],{2}],
		range 		= Range[Length@perm - Length@previousDummies-2]
	},
	Fold[
		Insert[#1, #2[[2]], #2[[1]] ]&,
		Insert[Insert[range, newDummy1, #[[1]]], newDummy2, #[[2]] ],
		positions
	]& /@ subsets
];




IndexConfigurations[expr_] := Module[
	{
		sym = SymmetryOf[expr],
		sgs, indices, len, perms
	},
	sgs 	= sym[[4]];
	indices = IndexSort[ IndexList @@ Last /@ sym[[3]] ];
	len 	= sym[[1]];
	perms	= TransversalInSymmetricGroup[
		sgs, 
  		Symmetric[Range@len] 
  	];
  	Union@Map[
  		UxSort@xAct`xTensor`Private`Reconstruct[
   			sym, 
   			{1, PermuteList[indices, InversePerm@#]}
		]&, 
		perms
	]
];


(***************************)
(* Young projectors et al. *)
(***************************)

TableauTranspose[tab_] := 
	Flatten[tab, {2}];

TableauDimension[tab_?YoungTableauQ] := 
	With[
	{
		f = Reverse@Range@Length[#] &
	}, 
		(Length@Flatten@tab)! / Times @@ Flatten[TableauTranspose[f /@ TableauTranspose@tab] + (f /@ tab) - 1]
	];

(* 
	I got the idea of using Young projectors from Guillaume Faye and Kaspar Peeters.
 	See http://groups.google.com/group/xact/browse_thread/thread/d19247526163ed62/986a5b04d4fa19f4 .
*)

YoungTableauQ[tableau:{{___Integer}...}|{{(-_Symbol|_Symbol)...}...}] := And[
	Reverse[Length /@ tableau] === Sort[Length /@ tableau],
	If[Length@tableau > 1, 
		Length@Union@Flatten@tableau === Length@Flatten@tableau, 
		True
	]
];
YoungTableauQ[_] := False;

ExprYoungQ[expr_,tableau_] := And[
	YoungTableauQ[tableau],
	Complement[Flatten[tableau],List@@IndicesOf[Free][expr]] === {}
];
TnsrYoungQ[tnsr_,tableau_] := And[
	YoungTableauQ[tableau],
	Total[Length /@ tableau] <= Length[SlotsOfTensor@tnsr]
];

Options[YoungSymmetrize] ^= {
	ManifestSymmetry -> Antisymmetric
};

YoungSymmetrize[expr_, tableau_, options___?OptionQ] := Module[{transpose, sym, manifest},
	manifest 	= ManifestSymmetry	/. CheckOptions[options] /. Options[YoungSymmetrize];
	transpose 	= TableauTranspose[tableau];
	If[manifest === Antisymmetric,
		sym = ToCanonical@Fold[Symmetrize[#1, #2] &, expr, tableau];
		sym	= ToCanonical@Fold[Antisymmetrize[#1, #2] &, sym, transpose];
	,
		sym	= ToCanonical@Fold[Antisymmetrize[#1, #2] &, expr, transpose];
		sym = ToCanonical@Fold[Symmetrize[#1, #2] &, sym, tableau];
	];
	sym	
] /; ExprYoungQ[expr,tableau];

YoungSymmetrize[tensor_?xTensorQ, tableau : {{___Integer} ...}, options___?OptionQ] := Module[{indices},
	indices = DummyIn /@ SlotsOfTensor@tensor;
	YoungSymmetrize[tensor @@ indices, indices[[#]] & /@ tableau, options]
] /; TnsrYoungQ[tensor,tableau];

YoungSymmetrize[tensor_?xTensorQ, options___?OptionQ] := Total[YoungSymmetrize[tensor, #] & /@ SymmetryTableauxOfTensor[tensor], options];

YoungProject[expr_, tableau_, options___?OptionQ] := Module[
	{
		dim	= TableauDimension[tableau],
		n	= Length@Flatten@tableau,
		n1	= Times @@ ( Factorial@Length[#]& /@ tableau ),
		n2  = Times @@ ( Factorial@Length[#]& /@ TableauTranspose@tableau )
	},	
	MapIfPlus[(# dim n1 n2 / n!)&, YoungSymmetrize[expr, tableau, options] ]
] /; ExprYoungQ[expr,tableau];

YoungProject[tensor_?xTensorQ, tableau : {{___Integer} ...}, options___?OptionQ] := Module[{indices},
   indices = DummyIn /@ SlotsOfTensor@tensor;
   YoungProject[tensor @@ indices, indices[[#]] & /@ tableau, options]
] /; TnsrYoungQ[tensor,tableau];


RiemannYoungRule[cd_?CovDQ, options___?OptionQ] := Module[
	{
		riemann, expr1, expr2, a, b, c, d, e
	},
	riemann		= GiveSymbol[Riemann, cd];
	{a,b,c,d,e}	= -GetIndicesOfVBundle[First@VBundlesOfCovD[cd], 5];
	expr1 		= riemann[a,b,c,d];
	expr2		= cd[e]@expr1;
	Join[
		If[expr1===0,{},MakeRule@Evaluate@{expr1, YoungProject[expr1, {{a,c},  {b,d}}, options]}],
		If[expr2===0,{},MakeRule@Evaluate@{expr2, YoungProject[expr2, {{a,c,e},{b,d}}, options]}]
	]	
];

RiemannYoungProject[expr_, cd_?CovDQ, options___?OptionQ] :=
	expr /. RiemannYoungRule[cd, options];

RiemannYoungProject[expr_, options___?OptionQ] := 
	Fold[RiemannYoungProject[#1, #2, options]&, expr, DeleteCases[$CovDs, PD]];


Options[YoungSymmetric] ^= {
	ManifestSymmetry -> Antisymmetric
}

TableauSymmetric[tableau_?YoungTableauQ, options___?OptionQ] := Module[
	{
		tab, manifestsym, transpose, sgs, cycles, samelengths, pairs, extracycles, sign
	},
	manifestsym = ManifestSymmetry	/. CheckOptions[options] /. Options[YoungSymmetric];
	transpose 	= TableauTranspose[tableau];
	
	(* The first set of cycles is simply the (anti)symmetrization of the tableau. *)
	sgs = If[manifestsym === Antisymmetric,
		Antisymmetric[#, Cycles]& /@ transpose,
		Symmetric[#, Cycles]& /@ tableau
	];
	cycles = sgs /. StrongGenSet[_List, GenSet[c___]] :> c;
	
	(* The second set of cycles comes from the additional symmetry present when two or more
	   rows or columns have the same length and can be interchanged. *)
	tab = If[manifestsym === Antisymmetric,
		transpose,
		tableau
	];
	samelengths = Select[
		(* Can't use GatherBy here, because that's MMA 7 and newer. *)
		Function[x, Select[tab, Length[#] === x &]] /@  DeleteDuplicates[Length /@ tab], 
		Length[#] > 1 &
	];

	If[manifestsym === Antisymmetric,
		sign = 1,
		sign = -1
	];
	pairs[list_List] := Cycles@@Transpose[{list[[#]], list[[#+1]]}]& /@ Range[Length@list - 1];
	extracycles = Flatten[ pairs /@ samelengths ] /. c_Cycles :> sign^Length[c] * c;
	
	(* The complete SGS is then: *)
	StrongGenSet[Union@@tableau, GenSet@@Join[cycles, extracycles]]
];



(**************************************)
(* Dimensional Depedendent Identities *)
(**************************************)

BasicDDIDefQ[cd_?CovDQ] := 
	BasicDDIDefQ[cd, DimOfManifold@ManifoldOfCovD@cd];
BasicDDIDefQ[__] = 
	False;

BasicDDIRelations[] := 
	Apply[Join, Map[BasicDDIRelations, $CovDs]];
BasicDDIRelations[cd_?CovDQ] := 
	BasicDDIRelations[cd, DimOfManifold@ManifoldOfCovD@cd];
BasicDDIRelations[__] = 
	{};
	
BasicDDITableaux[cd_?CovDQ] :=
	BasicDDITableaux[cd, DimOfManifold@ManifoldOfCovD@cd];

DefBasicDDI[cd_?CovDQ] := Module[
	{
		M 		= ManifoldOfCovD[cd],
		D 		= DimOfManifold@ManifoldOfCovD[cd],
		metric 	= MetricOfCovD[cd],
		basic, indices, tableau, asymmetrics, contractions, set, subsets, standard
	},
	
	(* Some preliminary tests. *)
	If[!IntegerQ[D] || D < 1,
		Throw::Message[
			DefBasicDD, 
			"Cannot define the basic DDI if the dimension of the manifold is not a positive integer."
		]
	];
	If[BasicDDIDefQ[cd, D],
		Return[]
	];
	
	(* Get the sorted lower indices of the tangent bundle. *)
	indices = ChangeIndex /@ Sort@GetIndicesOfVBundle[ First@VBundlesOfCovD@cd, 2(D+1) ];
	(* Construct the right Young tableau for the basic DDI. The Tranpose is to make sure 
	   the basic DDI will be antisymmetric in its first and last half set of indices. *)
	tableau = Transpose@Partition[indices, D+1];
	
	basic = GiveSymbol[BasicDDI, cd, D];
	
	(* Define the basic DDI. *)
	DefTensor[
		basic@@indices, 
		M, 
		TableauSymmetric[tableau, ManifestSymmetry -> Antisymmetric],
		PrintAs -> GiveOutputString[BasicDDI, cd, D],
		DefInfo -> {"basic dimensional dependent identity",""}
	];
	
	(* Rules for sending the basic DDIs to antisymmetrized metrics. *)
	asymmetrics = ToCanonical[
		(D+1)! Antisymmetrize[
			Apply[
				Times,
				metric@@#& /@ tableau
			],
			indices[[1;;D+1]]
		]
	];
	cd /: BasicDDIRelations[cd,D] = MakeRule[
		Evaluate@{basic@@indices, asymmetrics},
		PatternIndices -> All, TestIndices -> True, MetricOn -> All, UseSymmetries -> False
	];
	
	(* Make the basic DDI traceless. *)
	contractions = ContractMetric[
		basic@@indices * ( metric @@ # & /@ Subsets[ChangeIndex /@ indices, {2}] )
	];
	AutomaticRules[
		Evaluate[basic],
		Union@@(MakeRule[
			Evaluate@{#, 0}, 
			PatternIndices -> All, TestIndices -> True, MetricOn -> All, UseSymmetries -> False
		] & /@ contractions),
		Verbose -> False
	];
	
	(* Determine the independent index configurations of the basic DDI. These are in 1-to-1
	   correspondence with the Young tableaux of the basic DDI.
	   Instead of a 'proper' algorithm to find all standard tableaux, we'll use the following trick:
	   The first and last labels are always 1 and 2(D+1), otherwise the tableau is never standard.
	   The remaining 2D labels are uniquely fixed by choosing a subset of D labels for the left 
	   column and demanding that the tableau is standard, which fixes the right column.
	   This gives us slightly more tableaux than just the standard ones, so we select only 
	   the standard ones afterwards. *)
	
	(* Strip the first and last of the indices. *)
	set = Rest@Most@indices;
	(* Find all subsets of length D (i.e. all left rows). *)
	subsets = Subsets[set, {D}];
	(* Reinsert the first and the last of the indices and construct the right row. *)
	subsets = {
		Prepend[#,First@indices], 
		Append[Complement[set, #], Last@indices]
	}& /@ subsets;
	(* Select only the standard Young tableaux. *)
	standard = Select[subsets, And @@ OrderedQ /@ Transpose@# &];
	(* Store the standard tableaux. *)
	cd /: BasicDDITableaux[cd, D] = basic @@ Join @@ # & /@ standard;
	
	cd /: BasicDDIDefQ[cd, D] = True;
];

GiveOutputString[BasicDDI, covd_, dim_] := StringJoin["B", "[", SymbolOfCovD[covd][[2]], ",", ToString@dim, "]"];


ConstructDDIs[expr_,options___?OptionQ] := 
	ConstructDDIs[expr, IndexList[], options];

ConstructDDIs[expr_,freeIndices:(IndexList|List)[___?AIndexQ],options___?OptionQ] := 
	ConstructDDIs[expr, freeIndices, StrongGenSet[{},GenSet[]], options];

ConstructDDIs[expr_,freeIndices:(IndexList|List)[___?AIndexQ], symmetry_, options___?OptionQ] := Module[
	{
		auxT, auxTname, D, contractions, tensors, cd, basic, frees, tableaux, 
		ddis, verbose, symmethod, map, dummies
	},
	
	(* Set options. *)
	{verbose, symmethod, auxTname} = {Verbose, SymmetrizeMethod, AuxiliaryTensor} 
		/. CheckOptions[options] 
		/. Options[AllContractions];
		
	If[TrueQ[verbose],
		map = MapTimed,
		map = Map[#1,#2]&
	];
	
	If[auxTname =!= Default,
		auxT = auxTname
	];

	(* Init geometric variables. *)
	tensors = Union@Cases[expr, _?xTensorQ, {0, Infinity}, Heads -> True];
	cd 		= CovDOfMetric@First@MetricsOfVBundle@First@Cases[SlotsOfTensor /@ tensors, _?VBundleQ, {0, Infinity}, Heads -> True];
	D 		= DimOfManifold@ManifoldOfCovD@cd;
	basic 	= GiveSymbol[BasicDDI, cd, D];
	
	(* Define the basic DDI. *)
	DefBasicDDI[cd];
	
	(* Take all contractions of expr with 2(D+1) uncontracted indices. *)
	contractions = AllContractions[
		expr, freeIndices, symmetry,
		SymmetrizeMethod -> None, 
		UncontractedIndices -> 2(D + 1),
		FreeMetrics -> All, 
		AuxiliaryTensor -> auxT,
		Verbose -> verbose
	];
	
	If[contractions === {}, Return[{}]];
	
	frees 		= List@@IndicesOf[Free][First@contractions];
	dummies		= Union[UpIndex /@ IndicesOf[][contractions]];
	tableaux 	= ChangeFreeIndices[#, ChangeIndex /@ frees]& /@ BasicDDITableaux[cd,D];
	
	(* Take all possible combinations with the basic DDI.*)
	ddis = DeleteDuplicateFactors@map[
		ToCanonical,
 		Flatten@Outer[
			Times,
			tableaux,
			contractions
		],
		Description -> "Removing duplicate identities."
	];
	
	(* Expand the basic DDI. *)
	ddis = DeleteDuplicateFactors@map[
		ToCanonical@ContractMetric[# /. BasicDDIRelations[cd,D]]&,
		ddis,
		Description->"Expanding DDIs."
	];
	
	(* Remove the auxiliary tensor. *)
	ddis = DeleteDuplicateFactors@RemoveAuxT[ddis, auxT, freeIndices, dummies, symmethod];
	
	If[FreeQ[ddis,auxT],
		Block[{$UndefInfoQ=False},UndefTensor[auxT]]
	];
	
	(* Return. *)
	ddis
];

End[]