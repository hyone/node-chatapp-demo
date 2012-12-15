mongoose = require 'mongoose'

db = mongoose.connect 'mongodb://localhost/chat'

Message = new mongoose.Schema
  name:
    type: String
  message:
    type: String
  type:
    type: String
    default: 'message'
  created:
    type: Date
    default: Date.now

exports.Message = db.model 'Message', Message