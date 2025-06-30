# # app/graphql/mutations/upload_image.rb
# module Mutations
#   class UploadImage < BaseMutation
#     argument :file, ApolloUploadServer::Upload, required: true
#     # argument :ticket_id, ID, required: false

#     field :url, String, null: false

#     def resolve(file:, ticket_id: nil)
#       # Direct Cloudinary upload (no Active Storage)
#       result = Cloudinary::Uploader.upload(
#         file.tempfile,
#         folder: "ticket_attachments",
#         resource_type: "auto"
#       )

#       # if ticket_id
#       #   ticket = Ticket.find(ticket_id)
#       #   ticket.update!(image_url: result['secure_url'])
#       # end

#       { url: result['secure_url'] }
#     end
#   end
# end

module Mutations
  class UploadImage < BaseMutation
    argument :file_data, String, required: true  # Base64 encoded string
    argument :filename, String, required: true

    field :url, String, null: false

    def resolve(file_data:, filename:)
      result = Cloudinary::Uploader.upload(
        StringIO.new(Base64.decode64(file_data)),
        public_id: filename.split(".").first,
        folder: "ticket_attachments"
      )

      { url: result["secure_url"] }
    end
  end
end
