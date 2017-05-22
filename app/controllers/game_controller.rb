require 'open-uri'
require 'json'

class GameController < ApplicationController

  def game
   @start_time = DateTime.now
   @letters = []
   (0...10).each { @letters << rand(65..90).chr }
  end

  def score
    @start_time = DateTime.parse(params[:time])
    @end_time = DateTime.now
    @guess = params[:answer].upcase
    @given_letters = params[:given].chars.to_a
    @given_letters_hash = hash_letters(@given_letters)
    @guess_hash = hash_letters(@guess.chars.to_a)
    if check_letters_present(@guess_hash, @given_letters_hash)
      if check_translation(@guess)
        @time = (((@end_time - @start_time).to_f) * 24 * 60 * 60).round(2)
      else
        @time = 0
        @message = "That's not a word"
      end
    else
      @time = 0
      @message = "Letters not present in word!"
    end
  end

  def hash_letters(arr_letters)
    hash_letters = Hash.new { 0 }
    arr_letters.each { |letter| hash_letters[letter] += 1}
    return hash_letters
  end

  def check_letters_present(hash_attempt, hash_given)
    hash_attempt.each do |letter, _|
      if hash_attempt[letter] > hash_given[letter]
        return false
      end
    end
    return true
  end

  def check_translation(word)
    url1 = "https://api-platform.systran.net/translation/text/translate?"
    url2 = "source=en&target=fr&key=6c211614-ec27-4b94-b7f0-42904e188b60&input=#{word}"
    url = url1 + url2
    word_serialized = open(url).read
    word_output = JSON.parse(word_serialized)
    return word_output["outputs"][0]["output"] != word
  end
end
