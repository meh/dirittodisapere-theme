# -*- encoding : utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  # Remove UK-specific references to FOI
  InfoRequest.instance_eval do

    THEME_LAW_USED_READABLE_DATA =
      { :foi => { :short => 'accesso civico',
                  :full => 'Decreto Trasparenza (D.lgs. 33/2013)',
                  :with_a => _('A Freedom of Information request'),
                  :act => 'D.lgs. 33/2013' }
      }

  end

  InfoRequest.class_eval do
    def applicable_law
      begin
        THEME_LAW_USED_READABLE_DATA.fetch(law_used.to_sym)
      rescue KeyError
        raise "Unknown law used '#{law_used}'"
      end
    end
  end

  OutgoingMessage.class_eval do
    # Add intro paragraph to new request template
    def default_letter
      return nil if self.message_type == 'followup'

      <<-TEXT
Io sottoscritto _______
nato/a a ____________
il ________________
residente a ______________________
in Via __________________________________________________________________

CHIEDO

Ai sensi dell’art. 5, comma 2 del D.Lgs n. 33/2013, l’accesso e l’invio di
copia elettronica dei seguenti documenti, dati o informazioni

* ____

Ai sensi dell’art. 18-bis, comma 1 della Legge n. 241/1990 si resta in attesa
del rilascio immediato della ricevuta che attesti l’avvenuta presentazione
dell’istanza completa di tutti i contenuti previsti dalla predetta
disposizione.
      TEXT
    end
  end
end
