# coding: utf-8
class CLI
  @@prompt = TTY::Prompt.new

  def run
    response = greeting # greets user, asks whether register or login

    @user = response.eql?("Log in") ? login : register # handles user's choice

    main_menu
  end

  def greeting
    @@prompt.select("Hello!", "Log in", "Register")
  end

  def login
    email = @@prompt.ask("Please enter your email address:")
    return User.find_by(email: email) if User.find_by(email: email)

    failure_message = "We couldn't find a user with that email address. Would you like to try again or register a new account?"
    response = @@prompt.select(failure_message, "Try again", "Register new account")
    response.eql?("Try again") ? login : register
  end

  def register
    email = @@prompt.ask("Please enter your email address:")
    name = @@prompt.ask("What should we call you?")
    User.create(name: name, email: email)
  end

  def main_menu
    refresh_user

    options = ["Review a restaurant"]
    options << "Delete one of your reviews" unless @user.reviews.empty?
    options << "Exit"
    selection = @@prompt.select("Hi #{@user.name}, how can we help you today?", options)
    menu_selection(selection)
  end

  def refresh_user
    @user = User.find(@user.id)
  end

  def menu_selection(selection)
    case selection
    when "Exit"
      puts "Thank you for using our app!"
    when "Review a restaurant"
      review_restaurant
    when "Update a review"
      update_review
    when "Delete one of your reviews"
      delete_review
    end
  end

  def review_restaurant
    choice = choose_restaurant

    if choice.eql?("Add a new restaurant")
      new_restaurant = create_restaurant
      write_review(new_restaurant.name)
    else
      write_review(choice)
    end

    main_menu
  end

  def choose_restaurant
    @@prompt.select("x", Restaurant.random_names(10), "Add a new restaurant")
  end

  def create_restaurant
    Restaurant.create(name: @@prompt.ask("What is the restaurant called?"))
  end

  def write_review(restaurant_name)
    restaurant = Restaurant.find_by(name: restaurant_name)
    rating = @@prompt.ask("How many stars would you give #{restaurant.name}? (out of 5)")
    # use tty prompt slider for rating
    content = @@prompt.ask("Please write a review:")

    Review.create(
      rating: rating,
      content: content,
      restaurant_id: restaurant.id,
      user_id: @user.id
    )
  end

  def update_review
    chosen_review = choose_user_review("Which review would you like to update?")
  end

  def delete_review
    chosen_review = choose_user_review("Which review would you like to delete?")
    # add option to go back to main menu?
    confirm_message = "Are you sure you want to delete this review for #{chosen_review.restaurant.name}"
    if @@prompt.yes?(confirm_message)
      chosen_review.destroy
    end

    main_menu
  end

  def choose_user_review(message)
    # todo: two-step review choice (first choose restaurant, then choose review)
    @@prompt.select(message, @user.reviews_for_prompt)
  end
end
