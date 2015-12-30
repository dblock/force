_ = require 'underscore'
Q = require 'bluebird-q'
Backbone = require 'backbone'
Partners = require '../../../../collections/partners.coffee'
fetchCarouselPartners = require '../fetch_carousel_partners/fetch.coffee'

module.exports = (type) ->
  partners = new Partners

  Q.promise (resolve, reject) ->
    $.get '/geo/nearest', ({ name, latitude, longitude }) ->
      typeName = if type is 'gallery' then 'Galleries' else 'Institutions'
      category = new Backbone.Model name: "Featured #{typeName} near #{name}"
      options = near: "#{latitude},#{longitude}", type: type

      fetchCarouselPartners(options).then (partners) ->
        Q.all _.flatten partners.map (partner) -> [
          partner.related().profile.fetch()
          partner.related().locations.fetch()
        ]
        partners

      .then (partners) ->
        resolve
          category: category
          partners: partners

      .catch reject
      .done()
