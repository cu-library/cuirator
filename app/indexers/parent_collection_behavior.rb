# Functions to index work parent collection(s)
module ParentCollectionBehavior
    extend ActiveSupport::Concern
    
    # Recurse through object's member_of_collections attribute to identify
    # which collections are top-level collections (i.e., have no parents)
    def parent_collection_ids(object)
      return [] if object.nil?
      parents = object.member_of_collections
      ids = []
      parents.each do |parent|
        if parent.member_of_collections.empty?
            ids << parent.id 
        else
            ids += parent_collection_ids(parent)
        end
      end
      ids.uniq
    end
  
    def index_parent_collections(doc)
      parent_collection_ids = parent_collection_ids(object)
      subcollection_ids = doc['member_of_collection_ids_ssim'] - parent_collection_ids

      doc['member_of_parent_collections_ssim'] = parent_collection_ids.map{|id| SolrDocument.find(id).title.first}
      doc['member_of_subcollections_ssim'] = subcollection_ids.map{|id| SolrDocument.find(id).title.first}
      doc 
    end
  end