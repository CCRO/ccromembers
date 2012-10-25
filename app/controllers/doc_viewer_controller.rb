class DocViewerController < ApplicationController
	def upload
		begin
			uuid = Crocodoc::Document.upload(params['url'])
		rescue CrocodocError => e
		  puts 'failed :('
		  puts '  Error Code: ' + e.code
		  puts '  Error Message: ' + e.message
		end
		logger.info "UUID: " + uuid
		session_key = Crocodoc::Session.create(uuid, {
		    'is_editable' => true,
		    'user' => {
		        'id' => current_user.id,
		        'name' => current_user.name
		    },
		    'filter' => 'all',
		    'is_admin' => true,
		    'is_downloadable' => true,
		    'is_copyprotected' => false,
		    'is_demo' => false,
		    'sidebar' => 'visible'
		})
		
		redirect_to "https://crocodoc.com/view/" + session_key
	end

		def view

		session_key = Crocodoc::Session.create(params['uuid'], {
		    'is_editable' => true,
		    'user' => {
		        'id' => current_user.id,
		        'name' => current_user.name
		    },
		    'filter' => 'all',
		    'is_admin' => true,
		    'is_downloadable' => true,
		    'is_copyprotected' => false,
		    'is_demo' => false,
		    'sidebar' => 'visible'
		})
		
		redirect_to "https://crocodoc.com/view/" + session_key
	end
end
