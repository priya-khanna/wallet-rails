class HomeController < ApplicationController
  def index
    quote_text = quotes[rand(quotes.length)]
    @quote = quote_text.split('').each_with_index.map{|item, i| i%3 == 0 ? item.capitalize : item}.join('')
  end

  def about
  end

  private

  def quotes
    [
      "When life gives you lemons, make lemonode!",
      "Do something everyday for 3 weeks straight, and you can change your life completely!",
      "You only live once, but if you do it right, once is enough!",
      "Be the change that you wish to see in the world!",
      "No one can make you feel inferior without your consent",
      "Live as if you were to die tomorrow. Learn as if you were to live forever!",
      "There are only two ways to live your life. One is as though nothing is a miracle. The other is as though everything is a miracle!",
      "It is our choices that show what we truly are, far more than our abilities!",
      "Why are you so trying to fit in when you are born to stand out!",
      "Do not waste time searching for the right people, become the Right person yourself!",
      "It is never too late to be what you might have been!",
      "Its not the title that makes a person, Its what's in here!",
      "Do what you can, with what you have, where you are!",
      "Life isn't about finding yourself. Life is about creating yourself!",
      "Life is 10% what happens to us and 90% of how we react to it. We are in charge of our Attitudes!",
      "Do that thing which scares you!",
      "Don't freeze, don't stop, don't worry that it isn't good enough or it isn't perfect whatever it is: art or love or work or family or life!",
      "Remember to forgive yourself and to forgive others, it's too easy to be outraged these days, so much harder to change things, to reach out, to understand.",
      "Make your life filled with dreams and good madness. Read some fine books, watch great movies, make some art, write or draw or build or sing or live as only you can!",
      "Make mistakes. Make glorious amazing mistakes. Because if you are making mistakes, then you are making new things, trying new things, learning, living, pushing yourself, changing yourself, changing your world!"
    ]
  end
end
