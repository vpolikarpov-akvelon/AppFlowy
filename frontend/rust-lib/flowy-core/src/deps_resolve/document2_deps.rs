use std::sync::{Arc, Weak};

use appflowy_integrate::collab_builder::AppFlowyCollabBuilder;
use appflowy_integrate::RocksCollabDB;

use flowy_database2::DatabaseManager2;
use flowy_document2::deps::{DocumentCloudService, DocumentUser};
use flowy_document2::manager::DocumentManager;
use flowy_error::FlowyError;
use flowy_user::services::UserSession;

pub struct Document2DepsResolver();
impl Document2DepsResolver {
  pub fn resolve(
    user_session: Weak<UserSession>,
    _database_manager: &Arc<DatabaseManager2>,
    collab_builder: Arc<AppFlowyCollabBuilder>,
    cloud_service: Arc<dyn DocumentCloudService>,
  ) -> Arc<DocumentManager> {
    let user: Arc<dyn DocumentUser> = Arc::new(DocumentUserImpl(user_session));
    Arc::new(DocumentManager::new(
      user.clone(),
      collab_builder,
      cloud_service,
    ))
  }
}

struct DocumentUserImpl(Weak<UserSession>);
impl DocumentUser for DocumentUserImpl {
  fn user_id(&self) -> Result<i64, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().context("Unexpected error: UserSession is None"))?
      .user_id()
  }

  fn token(&self) -> Result<Option<String>, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().context("Unexpected error: UserSession is None"))?
      .token()
  }

  fn collab_db(&self) -> Result<Arc<RocksCollabDB>, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().context("Unexpected error: UserSession is None"))?
      .get_collab_db()
  }
}
