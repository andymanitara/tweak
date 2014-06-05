###
	@todo Build a syncing platform for saving to databased and getting from databases. This will not have any functionality to retrieving and saving in the database. The functionality behind this will be available in plugins, allowing for an extensive list of compatible databases.
	@note Any help with this functionality will be greatly appreciated. Or any suggestion on how to best achieve this will be helpful. Should it be extensive to all components, such as the configuartion so it can be retrived and dynamic building of components can be accomplished along with the data of models?
###
class tweak.Sync
  tweak.Extend(@, ['init'], tweak.Common)