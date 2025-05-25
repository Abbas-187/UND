const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.automateOrderStatus = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const orderId = context.params.orderId;

    let newStatus = null;
    // Example rules for automation
    if (after.items && after.items.every(item => item.fulfillmentStatus === 'fulfilled')) {
      newStatus = 'fulfilled';
    } else if (after.items && after.items.some(item => item.fulfillmentStatus === 'backordered')) {
      newStatus = 'backordered';
    }
    // Add more rules as needed (e.g., shipped, delivered, etc.)

    if (newStatus && after.status !== newStatus) {
      try {
        // Update order status and mark as automated
        await change.after.ref.update({
          status: newStatus,
          statusAutomatedBy: 'cloud',
          statusAutomatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Write to audit log
        await admin.firestore().collection('order_audit_trail').add({
          orderId,
          action: 'status_changed',
          prevStatus: after.status,
          newStatus: newStatus,
          automatedBy: 'cloud',
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          before: { status: after.status },
          after: { status: newStatus },
        });

        // Robust FCM notification
        const message = {
          topic: 'order-updates',
          notification: {
            title: 'Order Status Updated',
            body: `Order ${orderId} status changed to ${newStatus} automatically.`,
          },
          data: {
            orderId: orderId,
            newStatus: newStatus,
            automated: 'true',
          },
        };
        let fcmResult = null;
        try {
          fcmResult = await admin.messaging().send(message);
          // Log FCM success
          await admin.firestore().collection('order_audit_trail').add({
            orderId,
            action: 'notification_sent',
            notificationType: 'FCM',
            topic: 'order-updates',
            result: fcmResult,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (fcmError) {
          // Log FCM error
          await admin.firestore().collection('order_audit_trail').add({
            orderId,
            action: 'notification_failed',
            notificationType: 'FCM',
            topic: 'order-updates',
            error: fcmError.message || fcmError,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } catch (err) {
        // Log any other error in the automation process
        await admin.firestore().collection('order_audit_trail').add({
          orderId,
          action: 'automation_error',
          error: err.message || err,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Optionally, rethrow or handle as needed
      }
    }
  });