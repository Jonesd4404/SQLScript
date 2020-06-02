use Monsoon

update  Monsoon..AmazonCommissions
set EndDate = '1/1/2099';

update  Monsoon..AmazonCommissions
set EndDate = '2/28/2015'
where MediaType in ('Music','Videos (VHS)','DVDs','Video Game Accessories','ToysAndGames');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Music',	'Music',	'Music',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Videos (VHS)',	'Videos (VHS)',	'VHS Videos',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Videos (VHS)',	'Videos (VHS)',	'VhsVideos',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'DVDs',	'DVDs',	'DVDs',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'DVDs',	'DVDs',	'Dvds',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Video Game Accessories',	'Video Game Accessories',	'VideoGameAccessories',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Video Game Accessories',	'Video Game Accessories',	'Video Game Accessories',1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'ToysAndGames',	'ToysAndGames',	'Toys And Games',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'ToysAndGames',	'ToysAndGames',	'ToysAndGames',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Consumer Electronics',	'Consumer Electronics',	'Consumer Electronics',	0,	0.08,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Consumer Electronics',	'Consumer Electronics',	'ConsumerElectronics',	0,	0.08,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Home',	'Home',	'Home',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Miscellaneous',	'Miscellaneous',	'Miscellaneous',	.45,	0,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Musical Instruments',	'Musical Instruments',	'Musical Instruments',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Musical Instruments',	'Musical Instruments',	'MusicalInstruments',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Office Products',	'Office Products',	'Office Products',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

--insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
--values ('AmazonMarketplaceUS',	'Software',	'Software',	'Software',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Sports and Fitness',	'Sports and Fitness',	'SportsFitness',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Sports and Fitness',	'Sports and Fitness',	'Sports and Fitness',	0,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'VideoGames',	'Video Games',	'Video Games',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Default',	'Default',	'Default',	1.35,	0.15,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Photo Accessories',	'Photo Accessories',	'Photo Accessories',	0,	0.08,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');

insert into Monsoon..AmazonCommissions(SellerName,	Description,	MediaType,	MonsoonType,	FlatCommission,	CommissionPercent,	StartDate,	EndDate)
values ('AmazonMarketplaceUS',	'Photo Accessories',	'Photo Accessories',	'PhotoAccessories',	0,	0.08,	'2015-03-01 00:00:00.000',	'2099-01-01 00:00:00.000');









