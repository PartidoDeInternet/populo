require File.dirname(__FILE__) + '/acceptance_helper'

feature "Vote for proposals", %q{
  In order to change the mother fucking world
  As a citizen
  I want to vote for/against proposals
} do
  
  background do
    @user = create_user(:login => "123456789A")
    @user2 = create_user(:login => "123456789B")
    @user3 = create_user(:login => "123456789C")
  end
  
  scenario "Vote for open proposals" do
    login_as @user
    
    [["No",         "a votar en contra de"], 
     ["Sí",         "a votar a favor de"], 
     ["Abstencion", "a abstenerte de votar sobre"]].each do |vote, confirmation|
       
      proposal = create_proposal(:title => "Ley Sinde")
      
      visit proposal_path(proposal)
      click_button vote
      
      page.should have_content("Vas #{confirmation} la iniciativa “Ley Sinde”")
    
      click_button "Estoy seguro"
    
      page.should have_content("Tu voto ha sido contabilizado.")
    end
  end
  
  scenario "Can't vote if i'm not logged in" do
    proposal = create_proposal(:title => "Derogación del canon")
    
    visit proposal_path(proposal)
    click_button "Sí"
    
    page.should have_content("Autenticación requerida")
    page.should_not have_css("button", :text => "Confirmar")
      
    fill_in "Introduce tu usuario", :with => "123456789A"
    fill_in "Dinos tu contraseña", :with => "secret"
    click_button "Identifícate"
    
    page.should have_content("Vas a votar a favor de la iniciativa “Derogación del canon”")
  end

  scenario "Can't vote for closed proposals" do
    proposal = create_proposal(:closed_at => Date.yesterday, :official_resolution => "Derogada")
    
    login_as @user
    visit proposal_path(proposal)

    page.should have_content("La Propuesta fué Derogada en el Congreso")

    page.should_not have_css("button", :text => "Sí")
    page.should_not have_css("button", :text => "No")
    page.should_not have_css("button", :text => "Abstención")
    
    # Hacker-proof
    page.driver.post proposal_votes_path(proposal), :vote => {}
    Vote.count.should == 1
  end
 
  scenario "Can't vote twice for the same proposal" do
    proposal = create_proposal(:title => "Derogación del canon")
    
    login_as @user
    visit proposal_path(proposal)
        
    click_button "Sí"
    click_button "Estoy seguro"
    
    visit proposal_path(proposal)

    page.should have_content("Ya has votado esta propuesta")
        
    page.should_not have_css("button", :text => "Sí")
    page.should_not have_css("button", :text => "No")
    page.should_not have_css("button", :text => "Abstención")
    
    # Hacker-proof
    page.driver.post proposal_votes_path(proposal), :vote => {}
    
    Vote.count.should == 1
  end 
  
  scenario "Citizen vote results" do
    login_as @user
    proposal = create_proposal
    
    visit proposal_path(proposal)
    
    click_button "Sí"
    click_button "Estoy seguro"
    
    percentages_should_be(proposal, :in_favor => 100, :against => 0, :abstention => 0)
    number_of_votes_should_be(proposal, :in_favor => 1, :against => 0, :abstention => 0)
    
    login_as @user2
    visit proposal_path(proposal)
    click_button "No"
    click_button "Estoy seguro"
 
    percentages_should_be(proposal, :in_favor => 50, :against => 50, :abstention => 0)
    number_of_votes_should_be(proposal, :in_favor => 1, :against => 1, :abstention => 0)
    
    login_as @user3
    visit proposal_path(proposal)
    click_button "Abstencion"
    click_button "Estoy seguro"
    
    percentages_should_be(proposal, :in_favor => 33, :against => 33, :abstention => 33)
    number_of_votes_should_be(proposal, :in_favor => 1, :against => 1, :abstention => 1)

    page.should have_css(".in_favor", :text => "Sí")
    page.should have_css(".against", :text => "No")
    page.should have_css(".abstention", :text => "Abs")
  end
  
  scenario "Parlament vote results" do 
    login_as @user
    proposal = create_proposal(:closed_at => Date.yesterday, :official_resolution => "Aceptada")
    visit proposal_path(proposal)
    page.should have_css(".official_resolution", :text => "Aceptada")
  end
end