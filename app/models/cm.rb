class Cm < ActiveRecord::Base

	before_save :create_slug
	
	 def create_slug
	    self.slug = self.title.parameterize
	  end
	  
end
