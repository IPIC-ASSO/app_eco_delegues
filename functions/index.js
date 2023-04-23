const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('Messages/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idEnvoyeur = doc.envoyeur
    const contentMessage = doc.corps

    admin
      .firestore()
      .collection('Utilisateurs')
      .where('id', '==', idEnvoyeur)
      .get()
      .then(querySnapshot2 => {
        querySnapshot2.forEach(userFrom => {
          console.log(`Utilisateur envoyeur: ${userFrom.data().pseudo}`)
          const payload = {
            notification: {
              title: `Message de "${userFrom.data().pseudo}"`,
              body: contentMessage,
              badge: '1',
              sound: 'default'
            }
          }
          admin
            .firestore()
            .collection('Utilisateurs')
            .get()
            .then(querySnapshot => {
              querySnapshot.forEach(userTo => {
                console.log(`Destinataires trouvés: ${userTo.data().pseudo}`)
                if (userTo.data().pushToken && !userTo.data().co) {
                    admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Message envoyé avec succès:', response, 'à: ',userTo.data().pseudo)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                }else {
                    console.log('jeton destinataire introuvable')
                  }
              })
            }).catch(error => {
                console.log('Erreur destinataire:', error)
             });
     })
    }).catch(error => {
        console.log('Erreur envoyeur:', error)
   });


    /*// Get push token user to (receive)
    admin
      .firestore()
      .collection('Utilisateurs')
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Destinataires trouvés: ${userTo.data().pseudo}`)
          if (userTo.data().pushToken && !userTo.data().co) {
            // Get info user encore (sent)
            admin
              .firestore()
              .collection('Utilisateurs')
              .where('id', '==', idEnvoyeur)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Utilisateur envoyeur: ${userFrom.data().nickname}`)
                  const payload = {
                    notification: {
                      title: `Message de "${userFrom.data().nickname}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Message envoyé avec succès:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })*/
    return null
  })